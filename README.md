# 🗣️ 레츠톡 (Ret's talk)

<img src="https://github.com/user-attachments/assets/d73258bb-93f4-4dd7-8051-958d49816c77"/>

> 번거로운 회고, 저희가 도와줄게요. </br>
> 대화 형식으로 회고하는 회고 서비스 앱 "**레츠톡**"

<img src="https://github.com/user-attachments/assets/e974f1d1-db4a-4f02-91a3-e6ca8f417ea4"/>

## 🖐️ 다섯줄 소개

- 💬 회고를 대화하듯이 할 수 있어요.
- 🤓 회고의 요약을 볼 수 있어요.
- 🤔 회고를 리마인드 할 수 있도록 북마크 기능을 제공해요.
- 📳 회고를 잊지 않도록 알림을 보내드려요.
- ☁️ 회고를 iCloud에 연동할 수 있어요.

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

## 🙌 주요 기능

### AI 챗봇과 대화형 회고

- 사용자의 대화에 따라 챗봇이 개인화된 질문을 생성합니다.
- 회고를 종료하면 대화를 요약해 제공합니다.

### 회고 관리

- 중요한 회고는 고정해서 계속 리마인드 할 수 있고, 회고 달력을 통해서 살펴볼 수 있습니다.

### 매일 특정 시간에 회고 알림 제공

- 사용자가 원하는 시간에 회고를 할 수 있도록 리마인드 알람을 보냅니다.

### iCloud 연동

- iCloud 연동을 통해 기기를 변경하더라도 정보를 유지할 수 있습니다.

## 💾 핵심 경험

### Swift 6 동시성 그리고 데이터 격리

<details>
<summary>자세히 보기</summary>

저희의 애플리케이션은 회고 데이터를 관리합니다.

<img src="https://github.com/user-attachments/assets/66e871ce-82ee-4a9f-9720-084aad5b7e94" width="400">

회고를 관리하며 네트워크와 로컬 저장소의 비동기 작업들을 만나게 됩니다. 회고는 사용자에 요구에 의해 변하고, 화면에 보여줄 수 있도록 공유되어야 합니다.

즉, 여러 스레드에서 접근할 수 있는 가변 공유 데이터가 됩니다.

사용자가 신뢰할 수 있도록 데이터를 동시성의 상황에서 안전하게 관리해야 합니다.

동시성 코드는 올바르게 작성하기 힘들고, 유지 그리고 확장까지 하는 것은 더 큰 어려움입니다.

주요한 이유에서는 🔴**실행시간이 되어서야 뭔가 잘못되었다는 것을 알 수 있기 때문**입니다.

때로는 잘못 작성했는데, 실행 시간에 발견되지 않을 수도 있습니다.

---

애플에서도 이를 가엽게 여겨 2021년 Swift 동시성을 발표했고, 2024년 Swift 6가 나오며 동시성을 더 강화해 컴파일 시간에 데이터 경쟁을 감지할 수 있도록 했습니다.

이게 왜 가능할까요 ? 🟠**어떻게 실행시간에 알 수 있던 것을 정적인 컴파일 시간으로 가져올 수 있었을까요 ?**

이 부분에 대해 나름대로 해석을 해봤습니다. 잘못된 내용이 있을 수 있으며, 지적은 언제나 환영입니다.

이제부터 우리는 컴파일러가 되어 다음의 코드를 분석해 봅시다.

```swift
class BoostCamp {
    private(set) var campers: [Person]
    private let queue: DispatchQueue
    
    init() {
        campers = []
        queue = DispatchQueue(label: "com.naver.boostcamp.serialQueue")
    }
    
    func enroll(person: Person) {
        campers.append(person)
    }
}

// MARK: Conconrrency code

var naverBoostCamp = BoostCamp()

DispatchQueue.global().async {
    naverBoostCamp.enroll(Person("JK"))
}

DispatchQueue.global().async {
    naverBoostCamp.enroll(Person("BK"))
}
```

우리는 이 코드가 데이터 경쟁 문제를 야기할 수 있다는 것을 알 수 있지만, 컴파일러는 소스 코드를 바탕으로 어휘 구문 의미를 분석할 뿐, 실행 시간 데이터를 알 수 없습니다.

만일 더 복잡한 사항이고, 우리도 데이터 경쟁이 발생할 수 있다는 상황을 인지하지 못했다면 아마 끔찍한 상황으로 이어질 것입니다.

그러면 컴파일러가 동시성 문제를 알 수 있도록 하기 위해서 필요한 것은 무엇일까요 ?

관련한 정보를 더 제공하면 되지 않을까요 ?

- 이 데이터는 동시성의 상황에서 안전하게 처리된다.
- 저 데이터는 동시성의 상황에서 안전하지 않아서 주의해야 한다.

---

그렇게 `actor`를 도입해서 🔵**타입을 확장**하고, 🔵**데이터 격리의 개념**을 얻습니다. 크게 두 영역으로 나눌 수 있는데,

- 비격리 영역(non-isolated domain)
- 격리 영역(actor-isolated domain)

이제 컴파일러는 🚨`비격리 영역 - 다중 접근 가능`🚨, 🏝️`격리 영역 - 단일 접근만 허용`🏝️이라는 개념을 장착하고 동시성 문제를 파악할 수 있게 됩니다.

- 🚨비격리 → 🚨비격리: 다중 접근이 허용되는 곳끼리 문제는 없음.
- 🏝️격리 → 🚨비격리: 다중 접근이 허용되는 곳으로 가는 것은 문제 없음.
- 🏝️격리 → 같은 격리: 같은 격리 도메인에서 작업 수행은 문제 없음.

다음은 주의가 필요합니다.

- 🚨비격리 → 🏝️격리: 격리는 단일 접근만 허용하므로 차례를 기다려야함.
- 🏝️격리 → 🏝️다른 격리: 각 격리끼리도 단일 접근만 허용하므로 차례를 기다려야함.

격리간 소통하는 것은 위와 같이하면 됩니다.

---

격리가 다른 경우에 데이터를 전달해야 한다면 어떨까요 ?

그 데이터가 어떤 형식인가가 중요합니다. 데이터 경쟁에 위험이 있는 데이터라면 주고 받는 행위를 허용하지 않아야 합니다.

여기서 또 하나의 타입 개념을 도입합니다. 바로 `Sendable` !

보낼 수 있는 데이터, 더 자세하게는 🔵**안전하게 보낼 수 있는 데이터**를 의미합니다.

데이터 경쟁은 🔴**공유**되는 🔴**가변**데이터에 🔴**둘 이상의 접근에 하나 이상이 쓰기 작업**을 할 때 발생합니다.

그렇다면 데이터가 `Sendable`하기 위한 조건은 다음과 같습니다.

- 🔴 공유를 허용하지 않거나 → 순수 값타입(복사를 통한 전달)
- 🔴 값이 변하지 않거나 → 불변한 상수 값
- 🔴 상호 베타적 접근만 허용하거나 → 액터와 같은 타입

---

이제 다시 아래의 코드를 분석해 봅시다.

```swift
class BoostCamp {
    private(set) var campers: [Person]
    
    init() {
        campers = []
    }
    
    func enroll(person: Person) {
        campers.append(person)
    }
}

// MARK: Conconrrency code

var naverBoostCamp = BoostCamp()

Task {
    naverBoostCamp.enroll(Person("JK"))
}

Task {
    naverBoostCamp.enroll(Person("BK"))
}
```

BoostCamp라는 타입이 격리되어 있지 않음을 알 수 있습니다.

그리고 Task 동시성 환경에서 값을 변경하려 하는데, 이는 안전하지 않겠구나 판단할 수 있습니다.

이렇게 개념을 잡고 프로젝트에 적용해봤습니다.

![image](https://github.com/user-attachments/assets/e1381565-59ce-4668-ae1c-3a19c4de2b4a)

문제가 될 수 있는 부분을 살펴 봅시다.

회고 관리자와 회고 대화 관리자가 각각 격리가 되어 있습니다. 회고 대화 관리자는 회고 관리자로부터 회고 데이터를 받습니다. 그리고 회고 데이터는 둘 사이에서 계속 동기화가 되어야 합니다.

하지만 지금은 둘 사이가 격리되어 있습니다.

그래서 비동기의 상황에서 차례를 기다려야 합니다. 근데 변화가 여러번 생길 수 있으며 그때마다 비동기 태스크가 발생하면 문제가 됩니다.

![image](https://github.com/user-attachments/assets/761a7bad-fadd-4662-b2be-e3eeefacd4a7)

상호 베타적인 접근만 허용해서 저수준의 데이터 경쟁은 없는 것이 보장이 되지만, 🔴**여러개의 비동기 태스크가 어떤 순서로 수행되는지는 보장되지 않습니다.**

그렇게 고수준의 데이터 경쟁이 발생할 수 있습니다.

사실 이 둘 사이는 격리되어있을 이유가 없습니다. 둘은 의존관계에 있고, 상태 관리가 동기적으로 이뤄지는 것이 더욱 안전한 구조이기 때문입니다.

격리를 하는 것은 좋지만, 🟠**격리간의 데이터 송수신이 비동기가 되면서 문제가 될 수 있는 경우는 격리를 나누는 것이 좋은 선택은 아닙니다.**

정리를 하면,

![image](https://github.com/user-attachments/assets/941ed5cf-41bf-43b7-8873-bd2c3b42cea9)

격리는 두 영역으로, 메인 액터와 회고 액터로 나뉩니다.

메인 액터는 화면적 요소와 아주 가벼운 작업을 처리합니다.

회고 액터에서 네트워크, DB등의 무거운 작업을 처리하고 회고 데이터를 안전하게 보호합니다.

</details>

## 문서

| [WiKi](https://github.com/boostcampwm-2024/iOS01-boostproject/wiki) | [팀 노션](https://level-mole-239.notion.site/129124f2c5a480348bf1d5f4b1a4b5b7?pvs=4) | [그라운드룰](https://github.com/boostcampwm-2024/iOS01-boostproject/wiki/%EA%B7%B8%EB%9D%BC%EC%9A%B4%EB%93%9C%EB%A3%B0) | [컨벤션](https://github.com/boostcampwm-2024/iOS01-boostproject/wiki/%EC%BB%A8%EB%B2%A4%EC%85%98) | [회의록](https://level-mole-239.notion.site/129124f2c5a481cebb50e2ec49310ba2?pvs=4) | [기획/디자인](https://www.figma.com/design/zMfreNb94N10uKDHizHXF5/Ret's-Talk?node-id=66-1872&t=C78fv57BD0ACgwct-1) |
| :-----------------------------------------------------------------: | :----------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
