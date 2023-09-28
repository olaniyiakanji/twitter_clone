# Narration
I started the `twitter_clone` using the flutter framework. It's a cross-platform framework for building mobile and web applications from the same code-base accelerating app development. Flutter works by creating its own rendering engine: instead of transpiling or translating the code to native code (it doesn't), it depends on its own rendering engine and renders its own UI elements. This allows it a lot of flexibility and distances it away from hindrances such as internal bugs as well as complications that may arise with source-to-source compilation. In the case that the native platform exposes some APIs, those APIs can be communicated with through Method channels thereby reducing the trade-offs of this cross-platform framework. 

# Breakdown
### 1. Development tools
1) VScode and Android-studio were installed
2) Necessary SDKs where installed including the Flutter and Dart SDKs.
3) The Backend Client, Appwrite ~ A **B**ackend **a**s **a** **Service** (**BaaS**) setup locally using Docker.

### 2. Comparison of tools
I found out Android-studio had the best plugins and best modes for android-development, but I wanted to take advantage of the sheer number of plugins VScode had to offer.

Also, alternatively, Appwrite could be used without a local client but that could be tedious and app testing would then be subject to the whims of internet connectivity and speed. It could be said that this internet time overhead is small, however I do not consider it negligible. These small amounts accumulate as a continuum and becomes a retarding force.

### 3. Steps
1. I created the project using the command 

```bash
flutter create twitter_clone
```
Thereafter, flutter sets up the required files to start this project. 

2. This is what the project root looked like at the start: Desktop/twitter_clone/
├── analysis_options.yaml
├── android
├── Assets
├── build
├── ios
├── lib
├── linux
├── macos
├── pubspec.lock
├── pubspec.yaml
├── README.md
├── test
├── twitter_clone.iml
├── web
└── windows
3. We should not tamper with other folders but *lib* except in exceptional cases. Those folders chiefly contain native-code which opposes our goal.
4. After we compile what is in the *lib* and *test* folder, the result manifests in those folders that contain native_code and the compiled app package lives in the *build* folder.

### 4. Challenges
1. As I was unfamiliar with docker, it took me a while to actually study what was going on. I faced a few bugs trying to give permission to a certain docker command on my Linux PC

