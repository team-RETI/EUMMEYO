.DEFAULT_GOAL := all

# -------------------------
# Private 파일 다운로드 관련 코드
# -------------------------
Private_Repository=team-RETI/EUMMEYO-Private/main
BASE_URL=https://raw.githubusercontent.com/$(Private_Repository)
    
define download_file
	mkdir -p $(1)
	curl -H "Authorization: token $(2)" -o $(1)/$(3) $(BASE_URL)/$(1)/$(3)
endef

download-privates:
	@if [ ! -f .env ]; then \
		read -p "Enter your GitHub access token: " token; \
		echo "GITHUB_ACCESS_TOKEN=$$token" > .env; \
	else \
		echo ".env file already exists. Using existing token."; \
	fi
	make _download-privates

_download-privates:
	# .env 파일에서 GITHUB_ACCESS_TOKEN 읽기
	$(eval export $(shell cat .env))

	# 최상위 디렉토리에 Config.xcconfig 다운로드
	$(call download_file,.,$$GITHUB_ACCESS_TOKEN,Config.xcconfig)

	# 최상위 디렉토리에 GoogleService-Info.plist 다운로드
	$(call download_file,.,$$GITHUB_ACCESS_TOKEN,GoogleService-Info.plist)
	
	# EUMMEYO/Info.plist 파일 다운로드
	$(call download_file,EUMMEYO,$$GITHUB_ACCESS_TOKEN,Info.plist)

# -------------------------
# Homebrew 설치 확인 및 설치
# -------------------------
install_homebrew:
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Homebrew가 설치되어 있지 않습니다. 설치를 진행합니다..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
		echo "Homebrew가 이미 설치되어 있습니다."; \
	fi

# -------------------------
# fastlane 및 인증서 관련 작업
# -------------------------

# Homebrew로 fastlane 설치 (설치되어 있으면 업데이트)
install_fastlane: install_homebrew
	@echo "Updating Homebrew..."
	@brew update
	@echo "Installing fastlane via Homebrew..."
	@brew install fastlane || true
	@echo "✅ fastlane 설치 완료 (Homebrew 사용)"

# 인증서 다운로드 (readonly 모드)
fetch_certs: install_fastlane
	@echo "Fetching development certificates..."
	@fastlane match development --readonly
	@echo "Fetching appstore certificates..."
	@fastlane match appstore --readonly
	@echo "✅ 인증서 가져오기 완료"

# -------------------------
# 통합 기본 타겟: 필요한 경우 Private 파일과 인증서 모두 다운로드
# -------------------------
all: download-privates fetch_certs
	@echo "✅ 모든 작업 완료"
