# Creators Contents Guide
크리에이터들이 SNOW 컨텐츠를 작성할 수 있도록 돕는 자료들을 제공합니다.
스노우 엔진과 컨텐츠 구조에 대한 이해 그리고 루아스크립트로 컨텐츠를 작성하는 방법과 샘플, 라이브러리 등을 제공합니다.

## Settings
- Code Editor: [VSCode](https://code.visualstudio.com/)
- [Lua language server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
- [WebGL GLSL Editor](https://marketplace.visualstudio.com/items?itemName=raczzalan.webgl-glsl-editor)

## Getting Started
```shell
# Clone this repository
$ git clone https://github.com/CreatorsStudio-SNOW/LuaScript.git

# Set custom snippets into VSCode snippet setting
$ cp ./tools/vsSnippets/* ~/Library/Application\ Support/Code/User/snippets

# Creators Studio 메인화면에서 "열기(Open)" 으로 내려받은 Sample폴더를 지정해줍니다.

# 우상단의 "Sticker Driectory"을 클릭하여 폴더를 확인 후, 해당 경로를 VSCode에서 불러와줍니다.
```

<br>

## Samples
><details>
>  <summary>Details</summary>
>  <ul>
>  <li>Sample 01 : 기본적인 Scene구조와 script에서 B Type, F Type 노드를 삽입하고 TouchEvent를 통한 제어하는 방법을 배웁니다.</li><br>
>  <li>Sample 02 : 얼굴마다 다른 시나리오를주고싶을경우에 필요한 onPreRender 콜백에 대하여 FaceParticle예제를 통해 배웁니다.</li><br>
>  <li>Sample 03 : SnapshotNode, FrameBufferNode, ShaderNode, SegmentationNode를 이용한 예제를 통해 씬을 좀더 자유롭게 다루는법을 배웁니다. 또 툴에서 제공하는 다양한 PropertyNum들을 실시간으로 코드에 적용하여 테스트하는 방법을 배웁니다. </li><br>
>  <li>더 자세한 설명은 각 샘플 코드의 주석을 확인해주시기 바랍니다.</li><br>
>  <li>추가 예정 샘플 : 3D, Game 등</li><br>
  </ul>
</details>
<br>
<br>

## Coding Convention
> ## Naming  
> |Type|Rule|Example|
> |:-|:-|:-|
> |Variables|lowerCamelCase|camelCase = nil<br>backGroundColor = nil|
> |Constants|Uppercase+"_"|IMAGE_WIDTH = 70.0<br>IMAGE_HEIGHT = 100.0|
> |Global Variables|prefix **g_xx**|g_camelCase = nil<br>g_backGroundColor = nil|
> |Function|function **functionName**(param)<br>end|function initialize(scene)<br>print("initialize")<br>end|<br>
> <br>


> ## Allocation Order
> <details>
>  <summary>Details</summary>
>1. require<br>  
>2. Enum, Class<br>
>3. Constants<br>
>4. Callbacks<br>
>5. Other functions<br>
>
>```lua
>--script.lua allocation example
>--1. require
>require "KuruNodeKit/>KuruNodeKit.lua"
>
>--2. Enum, class
>GameState = {
>READY = 1,
>READY_TO_START = 2,
>PLAYING = 3,
>FAIL = 4,
>SUCCESS = 5
>}
>
>Game = {
>scene = nil,
>state = GameState.READY,
>score = 0,
>}
>
>--3. Constants
>MAX_COUNT = 3
>
>--4. Callbacks
>function initialize(scene)
>  print("initialize")
>end
>
>
>function frameReady(scene)
>  print("frameReady")
>end
>
>function finalize(scene)
>  print("finalize")
>end
>
>--5. Other Functions
>function myFunction()
>  print("myFunction")
>end
>```
</details>

<br>

## API Guide
- 준비 중입니다.



## Libraries
LuaScript를 통한 컨텐츠 개발 시 자주 사용되는 기능들을 쉽게 사용할 수 있도록 만든 라이브러리들입니다.<br>
각 라이브러리의 디렉토리에 간단한 기능 설명과 지원하는 버전을 제공하고 있습니다.
