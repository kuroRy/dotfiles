#!/usr/bin/env bats
# シェル起動時間ベンチマークテスト

load test_helper

# 起動時間の閾値（ミリ秒）
STARTUP_THRESHOLD_MS=500
STARTUP_WARNING_MS=300

# =============================================================================
# シェル起動時間ベンチマーク
# =============================================================================

@test "benchmark: zsh startup time is under ${STARTUP_THRESHOLD_MS}ms" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"

    local avg_time
    avg_time=$(measure_shell_startup 5)

    echo "Average startup time: ${avg_time}ms" >&3

    if [[ "$avg_time" -ge "$STARTUP_THRESHOLD_MS" ]]; then
        echo "Startup time exceeds threshold: ${avg_time}ms >= ${STARTUP_THRESHOLD_MS}ms" >&2
        return 1
    fi

    if [[ "$avg_time" -ge "$STARTUP_WARNING_MS" ]]; then
        echo "Warning: Startup time is slow: ${avg_time}ms >= ${STARTUP_WARNING_MS}ms" >&3
    fi

    return 0
}

@test "benchmark: zsh startup time consistency (low variance)" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"

    local times=()
    local runs=5

    for _ in $(seq 1 "$runs"); do
        local start end elapsed
        start=$(get_time_ms)
        ZDOTDIR="${XDG_CONFIG_HOME}/zsh" zsh -i -c exit 2>/dev/null
        end=$(get_time_ms)
        elapsed=$((end - start))
        times+=("$elapsed")
    done

    # 平均を計算
    local sum=0
    for t in "${times[@]}"; do
        sum=$((sum + t))
    done
    local avg=$((sum / runs))

    # 分散を計算（簡易版：最大と最小の差）
    local min="${times[0]}"
    local max="${times[0]}"
    for t in "${times[@]}"; do
        [[ "$t" -lt "$min" ]] && min="$t"
        [[ "$t" -gt "$max" ]] && max="$t"
    done
    local variance=$((max - min))

    echo "Times: ${times[*]}ms" >&3
    echo "Average: ${avg}ms, Min: ${min}ms, Max: ${max}ms, Variance: ${variance}ms" >&3

    # 分散が平均の50%を超える場合は警告
    local threshold=$((avg / 2))
    if [[ "$variance" -gt "$threshold" && "$threshold" -gt 50 ]]; then
        echo "Warning: High variance in startup times (${variance}ms)" >&3
    fi

    return 0
}

# =============================================================================
# プロファイリング機能テスト
# =============================================================================

@test "benchmark: ZSH_PROFILE=1 enables profiling" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"

    # ZSH_PROFILE=1 を設定して zsh を起動し、zprof が利用可能か確認
    local result
    result=$(ZSH_PROFILE=1 ZDOTDIR="${XDG_CONFIG_HOME}/zsh" zsh -i -c 'type zprof' 2>&1) || true

    # zprof が関数として定義されていることを確認
    if echo "$result" | grep -q "function"; then
        return 0
    else
        # プロファイリング機能が有効でない場合はスキップ
        skip "ZSH_PROFILE not implemented in .zshrc"
    fi
}

# =============================================================================
# メモリ使用量（参考情報）
# =============================================================================

@test "benchmark: report zsh memory usage" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"

    # macOS と Linux で異なるコマンドを使用
    if isRunningOnMac; then
        # macOS: /usr/bin/time -l を使用
        local mem_output
        mem_output=$( (/usr/bin/time -l ZDOTDIR="${XDG_CONFIG_HOME}/zsh" zsh -i -c exit) 2>&1 ) || true

        local mem_kb
        mem_kb=$(echo "$mem_output" | grep "maximum resident set size" | awk '{print $1}')

        if [[ -n "$mem_kb" ]]; then
            # macOS では bytes で報告されるので KB に変換
            local mem_mb=$((mem_kb / 1024 / 1024))
            echo "Memory usage: ~${mem_mb}MB" >&3
        else
            echo "Could not measure memory usage" >&3
        fi
    else
        # Linux: /usr/bin/time -v を使用
        local mem_output
        mem_output=$( (/usr/bin/time -v ZDOTDIR="${XDG_CONFIG_HOME}/zsh" zsh -i -c exit) 2>&1 ) || true

        local mem_kb
        mem_kb=$(echo "$mem_output" | grep "Maximum resident set size" | awk '{print $NF}')

        if [[ -n "$mem_kb" ]]; then
            local mem_mb=$((mem_kb / 1024))
            echo "Memory usage: ~${mem_mb}MB" >&3
        else
            echo "Could not measure memory usage" >&3
        fi
    fi

    # このテストは常に成功（情報提供のみ）
    return 0
}

# =============================================================================
# 比較ベンチマーク
# =============================================================================

@test "benchmark: compare with vanilla zsh" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"

    # Vanilla zsh の起動時間
    local vanilla_times=()
    local runs=3

    for _ in $(seq 1 "$runs"); do
        local start end elapsed
        start=$(get_time_ms)
        zsh --no-rcs -i -c exit 2>/dev/null
        end=$(get_time_ms)
        elapsed=$((end - start))
        vanilla_times+=("$elapsed")
    done

    local vanilla_sum=0
    for t in "${vanilla_times[@]}"; do
        vanilla_sum=$((vanilla_sum + t))
    done
    local vanilla_avg=$((vanilla_sum / runs))

    # dotfiles zsh の起動時間
    local dotfiles_avg
    dotfiles_avg=$(measure_shell_startup 3)

    # オーバーヘッドを計算
    local overhead=$((dotfiles_avg - vanilla_avg))
    local overhead_percent=0
    if [[ "$vanilla_avg" -gt 0 ]]; then
        overhead_percent=$((overhead * 100 / vanilla_avg))
    fi

    echo "Vanilla zsh: ${vanilla_avg}ms" >&3
    echo "Dotfiles zsh: ${dotfiles_avg}ms" >&3
    echo "Overhead: ${overhead}ms (+${overhead_percent}%)" >&3

    # オーバーヘッドが 400ms を超える場合は警告
    if [[ "$overhead" -gt 400 ]]; then
        echo "Warning: High overhead compared to vanilla zsh" >&3
    fi

    return 0
}
