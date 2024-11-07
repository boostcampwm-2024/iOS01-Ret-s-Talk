# 🗣️ 레츠톡 (Ret's talk)

<img src="https://github.com/user-attachments/assets/27bd7c3b-1cbb-4271-9069-c885d425b192"/>

> 번거로운 회고, 저희가 도와줄게요. </br>
> 대화 형식으로 회고하는 회고 서비스 앱 "**레츠톡**"

<img src="https://github.com/user-attachments/assets/b186ce0b-4c87-48d6-9ff0-8cfc180575dc"/>

## 🖐️ 다섯줄 소개

- 💬 회고를 대화하듯이 할 수 있어요.
- 🤓 회고의 요약을 볼 수 있어요.
- 🤔 회고를 리마인드 할 수 있도록 북마크 기능을 제공해요.
- 📳 회고를 잊지 않도록 알림을 보내드려요.
- 🤝 지인과 회고를 공유할 수 있어요.

## 🧑🏻‍💻 개발자들

<table>
<tr>
    <td align="center"><img src="https://github.com/gen-com.png" width="160"></td>
    <td align="center"><img src="https://github.com/alstjr7437.png" width="160"></td>
    <td align="center"><img src="https://github.com/MoonGoon72.png" width="160"></td>
    <td align="center"><img src="https://github.com/1win2.png" width="160"></td>
</tr>
<tr>
    <td align="center">S006_구병조</td>
    <td align="center">S013_김민석</td>
    <td align="center">S021_문영균</td>
    <td align="center">S066_조한승</td>
</tr>
<tr>
    <td align="center"><a href="https://github.com/gen-com" target="_blank">@gen-com</a></td>
    <td align="center"><a href="https://github.com/alstjr7437" target="_blank">@alstjr7437</a></td>
    <td align="center"><a href="https://github.com/MoonGoon72" target="_blank">@MoonGoon72</a></td>
    <td align="center"><a href="https://github.com/1win2" target="_blank">@1win2</a></td>
</tr>
</table>

## 🙌 v1.0 주요 기능

### AI 챗봇과 대화형 회고

- 사용자의 대화에 따라 챗봇이 개인화된 질문을 생성합니다.
- 회고를 종료하면 대화를 요약해 제공합니다.

### 매일 특정 시간에 회고 알림 제공

- 사용자가 원하는 시간에 회고를 할 수 있도록 리마인드 알람을 보냅니다.

## 😎 v2.0 주요 기능

### iCloud 연동

- iCloud 연동을 통해 기기를 변경하더라도 정보를 유지할 수 있습니다.

### 회고 공유 기능

- 회고를 다른 사람과 오프라인에서 공유할 수 있습니다.
- CloudKit으로 공유 폴더를 제공하여 그룹끼리 회고를 서로 확인할 수 있습니다.

## 💾 핵심 기술

<details>
<summary>자세히 보기</summary>

### Core Data

- 데이터의 **영구 저장**을 위해서 `Core Data`를 사용합니다.
- `Core Data`는 데이터를 객체 모델링할 수 있게 해주는 동시에, 관계형 데이터베이스처럼 데이터 간의 관계를 설정하고 관리할 수 있습니다.
- `Core Data`는 `iCloud`와 연동하여 여러 기기 간 데이터 동기화를 지원합니다. 이를 통해 사용자가 동일한 데이터를 다양한 Apple 기기에서 접근하고 수정할 수 있습니다.

### Network

- URL Loding System을 활용하여 프로젝트에 적합한 네트워크 도구를 직접 만듭니다.

### AI (Naver Clova Studio)

- 회고를 쉽게 하기 위해서 누군가와의 대화의 형식을 채택합니다. 지정된 형식보다는 `챗봇AI`를 통해 개인화된 질문을 주고 받을 수 있도록 합니다.
- 숏폼의 시대를 반영해, 긴 대화 회고를 `요약`해서 빠르게 읽고 찾을 수 있도록 합니다.

### UIKit + SwiftUI

- `SwiftUI`는 구조체와 함수형 프로그래밍 방식으로 좋은 성능과 안정성, 그리고 간결성을 가집니다. 하지만 아직까지 `UIKit`을 완전히 대체하지 못하기에, `UIKit`을 기반으로 두고 선택적으로 `SwiftUI`를 도입하도록 합니다.
    - 테이블뷰 셀 같은 화면을 간단하게 그리기 위해 `SwiftUI`를 일부 사용합니다.

### Swift Concurrency

- 기존 동시성 코드는 콜백을 활용해 제어 흐름이 여기저기 갈 수 있어 읽기 쉽지 않았으나, `Swift Concurrency`는 구조화된 제어 흐름으로 순서대로 나열되고 중첩될 수 있어 코드를 **위에서 아래로 직관적으로 읽을 수 있습니다**.
- DispatchQueue를 통한 멀티 스레드 프로그래밍은 스레드의 생성을 야기하며, 많은 양의 스레드가 생성되면 과한 문맥 교환을 초래해서 오히려 성능을 떨어뜨릴 수 있습니다. 이에 비해 `Swift Concurrency`는 스레드의 수를 코어의 수만큼으로 유지하고 가벼운 continuation 객체를 교환하기에 **성능적 이점을 얻으려 합니다.**

### Combine

- 네트워크 요청, Core Data 변경 사항과 같은 **연속적인 이벤트**를 **구독**하고 **반응**하기 위해 사용합니다.
- 메소드로 메시지를 주고 받으며 변화에 대응하는 방식보다, **관점을 옮겨 데이터의 변화에 대한 흐름을 생성**하고 그와 관련된 로직을 잇는 **반응형 프로그래밍**을 활용하려 합니다.

### Multipeer Connectivity

- 근처 지인들과 **오프라인**에서의 회고를 **공유**하기 위해 `Multipeer Connectivity`를 사용합니다.

### CloudKit

- 공유하는 데이터가 사진과 같이 **큰 데이터가 아니므로** `iCloud`에 저장합니다.
- `iCloud` 를 동기화하여 하나의 계정으로 여러 기기에서 같은 데이터를 사용할 수 있습니다.
- 공유 그룹을 만들어 폴더를 공유하기 위해 사용합니다.

</details>

## 문서

| [WiKi](https://github.com/boostcampwm-2024/iOS01-boostproject/wiki) | [팀 노션](https://level-mole-239.notion.site/129124f2c5a480348bf1d5f4b1a4b5b7?pvs=4) | [그라운드룰](https://github.com/boostcampwm-2024/iOS01-boostproject/wiki/%EA%B7%B8%EB%9D%BC%EC%9A%B4%EB%93%9C%EB%A3%B0) | [컨벤션](https://github.com/boostcampwm-2024/iOS01-boostproject/wiki/%EC%BB%A8%EB%B2%A4%EC%85%98) | [회의록](https://level-mole-239.notion.site/129124f2c5a481cebb50e2ec49310ba2?pvs=4) | [기획/디자인](https://www.figma.com/design/zMfreNb94N10uKDHizHXF5/Ret's-Talk?node-id=66-1872&t=C78fv57BD0ACgwct-1) |
| :-----------------------------------------------------------------: | :----------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
