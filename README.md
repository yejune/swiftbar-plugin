# SwiftBar-Plugin

이 프로젝트는 macOS 사용자를 위한 두 가지 주요 기능을 제공합니다: VPN 연결 관리와 암호화폐 가격 추적. 이 스크립트들은 SwiftBar 또는 BitBar와 같은 메뉴바 애플리케이션과 함께 사용하도록 설계되었습니다.

### 1. VPN 연결 관리자

#### 기능
- 현재 연결된 VPN의 상태를 메뉴바에 표시
- 연결 시간 추적
- 인터넷 연결 상태 확인
- VPN 연결/해제 기능
- 여러 VPN 연결 관리

#### 사용법
1. SwiftBar 또는 BitBar에 스크립트를 추가합니다.
2. 메뉴바 아이콘을 통해 VPN 상태를 확인할 수 있습니다.
3. 드롭다운 메뉴에서 각 VPN의 연결/해제가 가능합니다.

#### 주요 기능 설명
- 연결된 VPN이 있으면 눈 모양 아이콘과 함께 VPN 이름, 연결 시간이 표시됩니다.
- 인터넷 연결이 없으면 주황색으로 표시됩니다.
- 각 VPN에 대해 연결/해제 옵션이 제공됩니다.

### 2. 멀티 코인 가격 추적기

#### 기능
- 여러 거래소의 다양한 암호화폐 가격을 동시에 추적
- 메뉴바에 주 코인의 가격 표시
- 드롭다운 메뉴에서 모든 추적 중인 코인의 가격 확인 가능
- 각 코인에 대한 거래소 링크 제공

#### 사용법
1. `helpers/coins/` 디렉토리에 원하는 코인과 거래소에 대한 드라이버 스크립트를 추가합니다.
2. 메인 스크립트의 `COIN_DRIVERS` 배열에 추가한 드라이버를 등록합니다.
3. SwiftBar 또는 BitBar에 스크립트를 추가합니다.

#### 주요 기능 설명
- 메뉴바에는 첫 번째 코인의 가격이 표시됩니다.
- 드롭다운 메뉴에서 모든 추적 중인 코인의 가격과 거래소 정보를 확인할 수 있습니다.
- 각 코인에 대한 거래소 링크가 제공되어 빠르게 거래 페이지로 이동할 수 있습니다.
- 가격 조회 실패 시 오류 메시지가 표시됩니다.

## 설치 및 설정

1. SwiftBar 또는 BitBar를 설치합니다.
2. 이 저장소를 클론하거나 스크립트들을 다운로드합니다.
3. 스크립트들을 SwiftBar/BitBar 플러그인 디렉토리에 복사합니다.
4. SwiftBar/BitBar를 새로고침하거나 재시작합니다.
5. 스크립트에 실행 권한이 필요합니다.

## 주의사항

- 이 스크립트들은 macOS 환경에서 테스트되었습니다.
- 인터넷 연결이 필요합니다.
- 각 거래소의 API 사용량 제한을 확인하세요.

## 커스터마이징

- VPN 연결 관리자: 필요에 따라 타임아웃 값이나 인터넷 연결 확인 방식을 수정할 수 있습니다.
- 멀티 코인 가격 추적기: `helpers/coins/` 디렉토리에 새로운 코인/거래소 드라이버를 추가하여 확장할 수 있습니다.

## 문제 해결

스크립트 실행 중 문제가 발생하면 다음을 확인하세요:
1. 스크립트에 실행 권한이 있는지 확인
2. 필요한 의존성(curl 등)이 설치되어 있는지 확인
3. 인터넷 연결 상태 확인
4. 각 거래소의 API 상태 및 변경 사항 확인
