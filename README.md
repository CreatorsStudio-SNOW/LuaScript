# Creators Studio Developer Guide
This repository provides materials to help developers create SNOW content with scripting.   
It contains autocomplete tools for Kuru Engine, Samples, Libraries(kits) to script more comfortably.  

[`About Creators Studio`](http://creatorsstudio.snow.me/)

>## Settings
- [`Visual Studio Code`](https://code.visualstudio.com/)
- [`Lua language server`](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
- [`WebGL GLSL Editor`](https://marketplace.visualstudio.com/items?itemName=raczzalan.webgl-glsl-editor)  
- [`Kuru Snippets`](../tools)

>## Contents

* ### Samples
  [`1.Basic`](01_basic)

  [`2.FaceParticle`](02_faceparticle)

  [`3.Segmentation`](03_segmentation)

  `4.Todo` : 3D, Game .. 

* ### Code Convention
  * ### Naming  
     |Type|Rule|Example|
     |:-|:-|:-|
     |Variables|lowerCamelCase|camelCase = nil<br>backGroundColor = nil|
     |Constants|Uppercase+"_"|IMAGE_WIDTH = 70.0<br>IMAGE_HEIGHT = 100.0|
     |Global Variables|prefix **g_xx**|g_camelCase = nil<br>g_backGroundColor = nil|
     |Function|function **functionName**(param)<br>end|function initialize(scene)<br>print("initialize")<br>end|

  
  * ### Allocation Order
    `1. require`  
    `2. Enum, Class`  
    `3. Constants`  
    `4. Engine Callback Functions`  
    `5. Other functions`  

    <details>  
    <summary>Code Example</summary>  

    ```lua
    --1. require
    require "KuruNodeKit/KuruNodeKit.lua"

    --2. Enum, Class
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

    --4. Engine Callback Functions
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

* ### Kits
  [`Kit`](Libraries) is code modules(library) of frequently used features of Kuru API.make it easy to use frequently used features.  
  Each [`Kit`](Libraries) sample provides a brief description of the features and supported versions.

* ### Kuru API Guide
  - Document will open soon