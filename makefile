all: init link defaults packages

init:
	local/bin/init.sh

link:
	local/bin/link.sh

defaults:
	local/bin/defaults.sh

packages:
	local/bin/packages.sh install

# 後方互換性のため brew エイリアスを保持
brew: packages

brew-dump:
	local/bin/packages.sh dump

test:
	local/bin/test.sh

lint:
	local/bin/lint.sh

verify:
	local/bin/verify.sh

ci: test
	@echo "CI用の軽量テストを実行"

functional-test:
	@command -v bats >/dev/null 2>&1 || { echo "bats not installed. Run: brew install bats-core"; exit 1; }
	bats local/tests/

benchmark:
	@command -v bats >/dev/null 2>&1 || { echo "bats not installed. Run: brew install bats-core"; exit 1; }
	bats local/tests/benchmark.bats

test-all: test lint functional-test
	@echo "全てのテストが完了しました"

packages-status:
	@echo "現在のパッケージ管理状況を表示 (macOS)"
	@local/bin/packages.sh status