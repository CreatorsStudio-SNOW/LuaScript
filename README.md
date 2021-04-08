# Creators Contents Guide
외부 크리에이터들이 SNOW 컨텐츠를 작성할 수 있도록 돕는 자료들을 제공합니다.
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
$ cp ./vsSnippets/* ~/Library/Application\ Support/Code/User/snippets
```

#### Samples
<details>
  <summary>Samples</summary>
  Sample 01 - BackgroundImage, FaceSticker, TouchEvent
  Sample 02
  Sample 03
  Sample 04
  Sample 05
</details>
## Coding Convention

#### Naming  
|Type|Rule|Example|
|:-|:-|:-|
|Variables|lowerCamelCase|camelCase = nil<br>backGroundColor = nil|
|Constants|Uppercase+"_"|IMAGE_WIDTH = 70.0<br>IMAGE_HEIGHT = 100.0|
|Global Variables|prefix **g_xx**|g_camelCase = nil<br>g_backGroundColor = nil|


#### Allocation Order
<details>
  <summary>details</summary>
1. require
2. Enum, Class
3. Constants
4. Callbacks
5. Other functions

```lua
--script.lua allocation example
--1. require
require "KuruNodeKit/KuruNodeKit.lua"

--2. Enum, class
GameState = {
READY = 1,
READY_TO_START = 2,
PLAYING = 3,
FAIL = 4,
SUCCESS = 5
}

Game = {
scene = nil,
state = GameState.READY,
score = 0,
}

--3. Constants
MAX_COUNT = 3

--4. Callbacks
function initialize(scene)
  print("initialize")
end


function frameReady(scene)
  print("frameReady")
end

function finalize(scene)
  print("finalize")
end

--5. Other Functions
function myFunction()
  print("myFunction")
end
```

</details>



## Libraries
LuaScript를 통한 컨텐츠 개발 시 자주 사용되는 기능들을 쉽게 사용할 수 있도록 만든 라이브러리들입니다.<br>
각 라이브러리의 디렉토리에 간단한 기능 설명과 지원하는 버전을 제공하고 있습니다.