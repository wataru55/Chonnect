# Chonnect
「ちょっとした繋がり」を増やしたいエンジニアのための非接触型プロフィール交換アプリ

<img width="780" alt="スクリーンショット 2024-12-16 18 53 05" src="https://github.com/user-attachments/assets/9d8d9372-e719-4306-9651-e7663c79f8ee" />
<img width="1325" alt="スクリーンショット 2024-12-16 18 55 05" src="https://github.com/user-attachments/assets/ddb332ae-4b66-4f47-adc2-b8700524151a" />

<br>
<br>

## 受賞歴
2024年12月7日に行われた「チャレキャラ」のコンテストで最優秀賞とビジネス賞を受賞することができました。

<img src="https://github.com/user-attachments/assets/64026419-3ab6-4e45-8dfe-ef62664daa7f" alt="IMG_3041" width="600">

<br>
<br>

「福岡県ITスタートアップビジネス大賞2025公開審査会」に出場しました。

<img src="https://github.com/user-attachments/assets/adb0749f-c6f5-436e-b6a9-e4dad5468180" alt="IMG_3042" width="600">


<br>
<br>

## 開発の経緯
ハッカソンやインターン、カンファレンスなどのエンジニアが集まる場は、技術交流によって知識やアイデアを共有する絶好の場です。
しかし、初対面の人に話しかけるのは難しく、誰とも関わらないまま終わったり、連絡先を聞かずにイベントで築いた関係がその場限りで終わってしまった経験があります。
また、SNSの交換をしようとしても自分のIDを教えたり、検索したりするのは面倒です。
「このような経験をした人は自分だけではないはず」という思いから、小学生のときに夢中になった任天堂3DSのすれちがい通信からインスピレーションを受け、直接話しかけなくても相手がどんなエンジニアなのかが分かるアプリを開発しようと思いました。


<br>

## Chonnectが提供する価値
### １. 直接話しかけずに他のエンジニアと交流ができる
各ユーザーのプロフィールには以下の項目がまとめられており、BLE通信によってお互いが近づくと相手のプロフィールが確認できるようになります。
* 興味のある事柄
* 技術スタック
* Qiitaなどの技術記事のリンク
* 各種SNS

### ２. 話しかける前に相手の情報が分かる
すれちがった相手のプロフィールを事前に確認することで、会話のきっかけを得ることができ、交流をスムーズに進めることができます。

### ３. SNSの交換が簡単
プロフィールにはSNSのリンクがまとめられているため，IDを尋ねて手入力する必要がありません。

### ４. イベント後も交流ができる
すれちがった相手の情報は自動で履歴に保存されるため、会場で話すタイミングを逃した人ともイベント後に交流できます．


<br>

## 使用技術
* Swift/SwiftUI
* Firebase
  * Authentication
  * Cloud Firestore
  * Storage
  * App Check
  * Cloud Message
  * Cloud Functions
* Realm
* Bluetooth(BLE)

<img width="500" alt="スクリーンショット 2024-12-16 18 57 25" src="https://github.com/user-attachments/assets/047f4931-3745-4901-b0b5-59eb75c1bf65" />

<br>
<br>

## こだわりポイント
### １. BLE通信ですれちがい通信を再現
位置情報を利用したすれちがい通信が一般的ですが、バッテリー消費量に大きな懸念があったためChonnectでは、BLE通信のみですれちがい通信を再現しました。

### ２. バックグラウンドでのプロフィール交換
Appleの制約により、アプリがバックグラウンド状態ではBLE通信によってデータを送信することができません。ただし、受信はバックグラウンド状態でも可能です。

そのため、一方のデバイスがバックグラウンドで、もう一方がフォアグラウンドの場合、片方だけが相手のプロフィールを受信・確認できるという不公平な状況が生じる可能性がありました。
この問題を解決するために、サーバーを介してデータを補完する仕組みを導入しました。

具体的には、片方のデバイスが送信したデータをサーバーに保存し、相手側のデバイスがオンライン状態になったタイミングで、そのデータを受信できるようにしています。
これにより、公平なプロフィール交換を実現しました。

ただし、両方のデバイスがバックグラウンド状態の場合や、タスクキルされてアプリが起動されていない場合は、プロフィール交換はできません。

### 3. プッシュ通知の実装
２番を踏まえて、プロフィール交換を行うにはアプリを起動してもらう必要があります。そこで、他のユーザーからフォローされた時にプッシュ通知が届く仕組みを実装しました。

### ４. セキュリティの強化
Chonnectでは、ユーザーの情報を安全に管理するため、３段階のセキュリティ対策を導入しています。
* Firebase AppCheckの導入<br>
  データベースへのリクエストが正規のアプリから送られたものであることを保証します。
  
* Firebaseセキュリティルールの適切な設定<br>
  セキュリティルールを細かく設定することで、ユーザーごとの読み込みや書き込みリクエストを制限しています。
  
* SNSリンクへのアクセス制限<br>
  相手のユーザーと相互フォローの状態でない場合、SNSリンクへのアクセスを制限しています。

<img width="700" alt="スクリーンショット 2024-12-16 18 59 42" src="https://github.com/user-attachments/assets/e12f2674-4533-4a6d-8833-cbca5368f1d3" />

### 5. 洗練されたUI
チープに見えないよう、UIの実装にこだわっています。第三者にテストしてもらい、客観的なフィードバックをもとに改善を行いました。

| スクリーンショット | 説明 |
|--------------------|------|
| <img src="https://github.com/user-attachments/assets/20e8f1d0-f4d0-45fb-80e6-4e9ad864767b" width="200"> | ログイン画面: ログイン、新規登録、パスワードリセット |
| <img src="https://github.com/user-attachments/assets/c44a117e-d5b0-4d3b-a531-9a73c4205c83" width="200"> | マイプロフィール画面(上):  |
| <img src="https://github.com/user-attachments/assets/4e523e80-cd59-40bf-902d-648c74a0d692" width="200"> | マイプロフィール画面(下): |
| <img src="https://github.com/user-attachments/assets/4df9d565-59ff-4d97-833a-0b58a49a88e1" width="200"> | プロフィール編集画面:  |
| <img src="https://github.com/user-attachments/assets/0261595b-bc72-46c3-abe1-3707c877a589" width="200"> | すれちがい履歴表示画面:  |
| <img src="https://github.com/user-attachments/assets/6b6d11e8-0ef8-41cf-b229-80c12131bd88" width="200"> | 技術スタック一覧画面:  |
| <img src="https://github.com/user-attachments/assets/eac8684f-b1d7-4ab9-a9e7-779af78432ca" width="200"> | 技術タグ編集画面:  |
| <img src="https://github.com/user-attachments/assets/30bf858f-d152-4009-b2b9-15e0838bb640" width="200"> | 技術タグ編集画面: |
| <img src="https://github.com/user-attachments/assets/a8c64171-dec2-4e5e-86f9-4c9d5d452585" width="200"> | SNSリンク編集画面:  |
| <img src="https://github.com/user-attachments/assets/435214fc-1269-4877-8601-f707580a75e9" width="200"> | 記事編集画面: |
| <img src="https://github.com/user-attachments/assets/bf12a2f7-4318-48d0-b20e-b1d4b7ba8fc0" width="200"> | 設定画面: |




