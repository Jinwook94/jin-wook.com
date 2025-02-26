#!/bin/bash

set -e  # 에러 발생 시 즉시 종료

# 간단한 로깅 함수 (시각 및 스크립트명 포함)
log() {
    echo "[$(date '+%Y-%m-%dT%H:%M:%S')][$0] $1"
}

# 변수 설정
S3_BUCKET="jin-wook.com"
CLOUDFRONT_DISTRIBUTION_ID="E22O69CJQWKHUE"
AWS_PROFILE="cac-sso-shared-service"
BUILD_COMMAND="build:prod"

# 배포 확인
echo -e "\033[33m'$S3_BUCKET' 웹사이트를 배포하시겠습니까? (y/yes): \033[0m"
read -r confirm
if [[ "$confirm" != "y" && "$confirm" != "yes" ]]; then
    log "배포가 취소되었습니다."
    exit 0
fi

# 스크립트 위치 기준으로 프로젝트 루트 찾기
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT="$SCRIPT_DIR/.."

log "Vite 프로젝트 빌드 시작: npm run $BUILD_COMMAND"
cd "$PROJECT_ROOT"
npm run "$BUILD_COMMAND"

log "기존 S3 파일 삭제 중: $S3_BUCKET"
aws s3 rm "s3://$S3_BUCKET" --recursive --profile "$AWS_PROFILE"

# dist 폴더로 이동
cd "$PROJECT_ROOT/dist"

log "새 빌드 파일 업로드 중: dist -> s3://$S3_BUCKET"
aws s3 cp . "s3://$S3_BUCKET" --recursive --profile "$AWS_PROFILE"

# CloudFront 캐시 무효화
log "CloudFront 캐시 무효화 중: $CLOUDFRONT_DISTRIBUTION_ID"
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
    --paths "/*" \
    --profile "$AWS_PROFILE" \
    --query 'Invalidation.Id' \
    --output text)
log "CloudFront 무효화 생성됨: $INVALIDATION_ID"

log "정적 파일 배포 완료! 웹사이트는 https://$S3_BUCKET 에서 확인할 수 있습니다."