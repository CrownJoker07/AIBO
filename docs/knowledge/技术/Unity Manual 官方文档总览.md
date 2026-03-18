# Unity Manual 官方文档总览

## 文档信息

- **来源**: https://docs.unity3d.com/Manual/index.html
- **文档类型**: Unity 官方用户手册
- **获取日期**: 2026-03-18
- **文档标题**: Unity User Manual

---

## 文档结构概览

Unity Manual 分为以下几个主要部分：

| 部分 | 描述 |
|------|------|
| **Unity User Manual** | 使用 Unity 编辑器和引擎的综合指南 |
| **Unity Scripting API** | 脚本编程接口参考文档 |
| **Unity Services** | Unity 云服务和变现服务 |
| **Learning Resources** | 学习资源、教程和示例项目 |

---

## 核心概念

### GameObject（游戏对象）

Unity 中的一切都是 GameObject。每个 GameObject 包含：

| 组件 | 功能 |
|------|------|
| **Transform** | 位置、旋转、缩放（必需组件） |
| **Mesh Renderer** | 渲染 3D 模型 |
| **Mesh Filter** | 存储网格数据 |
| **Collider** | 物理碰撞检测 |
| **Rigidbody** | 物理模拟 |
| **Scripts** | 自定义行为 |

### Component（组件）

组件是附加到 GameObject 的功能模块：

- **添加方式**: Inspector 面板 → Add Component
- **访问方式**: `GetComponent<Type>()`
- **生命周期**: 与 GameObject 绑定

### Prefab（预制件）

预制件是可重用的 GameObject 模板：

| 特性 | 说明 |
|------|------|
| **实例化** | 从 Prefab 创建场景中的实例 |
| **继承** | 修改 Prefab 会影响所有实例 |
| **覆盖** | 实例可以有独立于 Prefab 的修改 |
| **嵌套** | Prefab 可以包含其他 Prefab |

### Scene（场景）

场景是游戏内容的容器：

- 每个 Scene 文件代表一个关卡或菜单
- 包含 GameObject、环境设置、光照配置
- 支持运行时异步加载（`SceneManager.LoadSceneAsync`）

---

## 编辑器工作流

### 项目结构

```
Assets/
├── Scenes/          # 场景文件
├── Scripts/         # C# 脚本
├── Prefabs/         # 预制件
├── Materials/       # 材质
├── Textures/        # 纹理
├── Models/          # 3D 模型
├── Audio/           # 音频文件
├── Animations/      # 动画
├── Fonts/           # 字体
└── Resources/       # 运行时加载资源
```

### Inspector 窗口

- 查看和编辑 GameObject 属性
- 添加/移除组件
- 预览资源

### Hierarchy 窗口

- 场景中所有 GameObject 的树形视图
- 拖拽创建父子关系
- 右键菜单快速创建对象

### Project 窗口

- 浏览 Assets 文件夹
- 搜索和过滤资源
- 拖拽资源到场景

### Scene 视图

- 3D 场景可视化编辑
- Gizmos 工具显示
- 多种渲染模式（Shaded、Wireframe、Shadow Cascades 等）

### Game 视图

- 游戏运行时预览
- 分辨率模拟
- Stats 面板显示性能数据

---

## 资源管线

### 资源导入流程

1. **拖拽文件到 Assets 文件夹**
2. **Unity 自动检测并导入**
3. **导入设置在 Inspector 中配置**
4. **Meta 文件存储导入配置和 GUID**

### Meta 文件

每个资源都有对应的 `.meta` 文件：

- 存储 GUID（全局唯一标识符）
- 导入设置
- 资源依赖关系

### 资源类型与导入设置

| 资源类型 | 关键设置 |
|----------|----------|
| **Texture** | Max Size、Compression、Format、Mipmap |
| **Model** | Scale Factor、Mesh Compression、Animation Import |
| **Audio** | Load Type、Compression Format、Quality |
| **Video** | Transcode、Resolution、Codec |

---

## 脚本基础

### MonoBehaviour 生命周期

```
初始化阶段:
├── Awake()      # 最先调用，用于初始化
├── OnEnable()   # 对象激活时
├── Start()      # Awake 后第一帧，用于依赖初始化
│
物理阶段:
├── FixedUpdate()   # 固定时间步长，物理计算
├── OnTriggerEnter/Exit/Stay
├── OnCollisionEnter/Exit/Stay
│
输入阶段:
├── Update()        # 每帧调用，处理输入
├── LateUpdate()    # Update 后调用，相机跟随
│
渲染阶段:
├── OnPreRender()
├── OnRenderObject()
├── OnPostRender()
│
销毁阶段:
├── OnDisable()     # 对象禁用时
├── OnDestroy()     # 对象销毁时
```

### 序列化

```csharp
// Inspector 中显示
public int publicField;

// 私有字段也可显示
[SerializeField] private int privateField;

// 引用类型
[SerializeField] private GameObject targetObject;
[SerializeField] private Transform targetTransform;
[SerializeField] private Rigidbody targetRigidbody;

// 数组和列表
[SerializeField] private int[] intArray;
[SerializeField] private List<string> stringList;
```

### 协程（Coroutines）

```csharp
// 启动协程
StartCoroutine(MyCoroutine());

// 定义协程
IEnumerator MyCoroutine()
{
    yield return null;              // 等待一帧
    yield return new WaitForSeconds(1f);  // 等待秒数
    yield return new WaitForEndOfFrame(); // 等待帧结束
    yield return StartCoroutine(AnotherCoroutine()); // 等待另一协程
}

// 停止协程
StopCoroutine(MyCoroutine());
StopAllCoroutines();
```

---

## 输入系统

### 传统输入管理器（Input Manager）

```csharp
// 键盘
Input.GetKey(KeyCode.Space);      // 持续按住
Input.GetKeyDown(KeyCode.Space);  // 按下瞬间
Input.GetKeyUp(KeyCode.Space);    // 释放瞬间

// 鼠标
Input.GetMouseButton(0);          // 0=左键, 1=右键, 2=中键
Input.mousePosition;              // 鼠标位置

// 轴向输入
Input.GetAxis("Horizontal");      // -1 到 1，有平滑
Input.GetAxisRaw("Horizontal");   // -1, 0, 1，无平滑
```

### 新输入系统（Input System Package）

- 基于事件驱动
- 支持多种输入设备统一抽象
- PlayerInput 组件简化输入处理
- Input Actions 资产可视化配置

---

## 物理系统

### 2D vs 3D 物理对比

| 3D 物理 | 2D 物理 |
|---------|---------|
| Rigidbody | Rigidbody2D |
| Collider | Collider2D |
| Physics | Physics2D |
| RaycastHit | RaycastHit2D |

### 刚体类型

| 类型 | 描述 | 用途 |
|------|------|------|
| **Dynamic** | 受力和碰撞影响 | 玩家、敌人 |
| **Kinematic** | 不受力，可编程控制 | 移动平台、门 |
| **Static** | 不移动 | 地面、墙壁 |

### 碰撞检测

```csharp
// 触发器（不产生物理碰撞）
void OnTriggerEnter(Collider other) { }
void OnTriggerExit(Collider other) { }
void OnTriggerStay(Collider other) { }

// 碰撞（产生物理碰撞）
void OnCollisionEnter(Collision collision) { }
void OnCollisionExit(Collision collision) { }
void OnCollisionStay(Collision collision) { }
```

### 射线检测

```csharp
// 3D 射线
RaycastHit hit;
if (Physics.Raycast(origin, direction, out hit, maxDistance, layerMask))
{
    Debug.Log("Hit: " + hit.collider.name);
    Debug.Log("Point: " + hit.point);
    Debug.Log("Normal: " + hit.normal);
}

// 2D 射线
RaycastHit2D hit2D = Physics2D.Raycast(origin, direction, distance, layerMask);
if (hit2D.collider != null)
{
    Debug.Log("Hit 2D: " + hit2D.collider.name);
}
```

---

## 动画系统

### Animator Controller

- 状态机控制动画播放
- 参数控制状态转换（Float、Int、Bool、Trigger）
- Blend Tree 实现动画混合

### Animation Clip

- 存储动画数据
- 可以是导入的或 Unity 内创建
- 支持动画事件

### 常用代码

```csharp
private Animator animator;

void Start()
{
    animator = GetComponent<Animator>();
}

void Update()
{
    // 设置参数
    animator.SetFloat("Speed", currentSpeed);
    animator.SetBool("IsGrounded", isGrounded);
    animator.SetTrigger("Jump");

    // 获取参数
    float speed = animator.GetFloat("Speed");

    // 获取当前状态信息
    AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);
    if (stateInfo.IsName("Base Layer.Jump"))
    {
        // 正在播放跳跃动画
    }
}
```

### Avatar 系统

- 用于动画重定向
- 将骨骼映射到标准人体骨骼
- 同一动画可应用于不同角色模型

---

## UI 系统

### 三种 UI 系统

| 系统 | 描述 | 用途 |
|------|------|------|
| **UI Toolkit** | 现代 UI 系统，基于 Web 技术 | 编辑器 UI、游戏 UI |
| **uGUI** | Unity 4.6+ 的 Canvas 系统 | 游戏内 UI |
| **IMGUI** | 即时模式 GUI | 编辑器扩展、调试 |

### uGUI 核心

```
Canvas (画布)
├── 渲染模式: Screen Space - Overlay/Camera, World Space
├── Canvas Scaler: 响应式布局
└── UI 元素
    ├── Text
    ├── Image
    ├── Button
    ├── Toggle
    ├── Slider
    ├── Scroll View
    └── Input Field
```

### Event System

- 处理 UI 事件
- 需要场景中有 EventSystem 对象
- 支持鼠标、触摸、键盘、控制器输入

---

## 音频系统

### 核心组件

| 组件 | 功能 |
|------|------|
| **Audio Source** | 发出声音 |
| **Audio Listener** | 接收声音（场景中通常只有一个） |
| **Audio Clip** | 音频文件数据 |
| **Audio Mixer** | 混音和效果处理 |

### Audio Source 设置

| 属性 | 说明 |
|------|------|
| **Volume** | 音量 (0-1) |
| **Pitch** | 音调 (0-3) |
| **Loop** | 循环播放 |
| **Spatial Blend** | 2D/3D 混合 (0=2D, 1=3D) |
| **Min/Max Distance** | 3D 声音衰减范围 |

---

## 导航与 AI

### NavMesh 系统

- 烘焙导航网格
- NavMeshAgent 组件控制移动
- 支持动态障碍物（NavMeshObstacle）

### 基本使用

```csharp
private NavMeshAgent agent;

void Start()
{
    agent = GetComponent<NavMeshAgent>();
    agent.SetDestination(targetPosition);
}

void Update()
{
    if (!agent.pathPending && agent.remainingDistance < 0.5f)
    {
        // 到达目的地
    }
}
```

---

## 构建与发布

### 支持平台

| 平台 | 说明 |
|------|------|
| **Windows/Mac/Linux** | 桌面平台 |
| **iOS/Android** | 移动平台 |
| **WebGL** | 浏览器 |
| **PlayStation/Xbox/Nintendo Switch** | 主机平台 |
| **Vision Pro/Quest** | XR 平台 |

### Player Settings 关键配置

- Company Name / Product Name
- Version / Bundle Version
- Scripting Backend (Mono2x / IL2CPP)
- API Compatibility Level
- Target Architecture
- Graphics APIs

### 构建流程

1. **File → Build Settings**
2. **添加场景到 Scenes In Build**
3. **选择目标平台**
4. **Switch Platform（如需要）**
5. **Player Settings 配置**
6. **Build / Build And Run**

---

## 调试与性能分析

### Debug 类

```csharp
Debug.Log("普通日志");
Debug.LogWarning("警告");
Debug.LogError("错误");
Debug.DrawRay(origin, direction, Color.red, duration);
Debug.DrawLine(start, end, Color.blue);
```

### Profiler 工具

- **CPU Usage**: 脚本和引擎开销
- **GPU Usage**: 渲染开销
- **Memory**: 内存分配和 GC
- **Rendering**: Draw Calls、三角形数
- **Audio**: 音频资源

### 性能优化要点

| 领域 | 优化方法 |
|------|----------|
| **渲染** | 减少 Draw Calls、使用 LOD、遮挡剔除 |
| **脚本** | 避免每帧分配、使用对象池、缓存组件引用 |
| **物理** | 使用简化的碰撞体、调整 Fixed Timestep |
| **内存** | 及时释放资源、合理使用 Resources.UnloadUnusedAssets |

---

## 包管理

### Package Manager

- **Window → Package Manager**
- 官方包、预览包、本地包
- manifest.json 管理依赖

### 常用包

| 包名 | 用途 |
|------|------|
| **Universal RP** | 通用渲染管线 |
| **HDRP** | 高清渲染管线 |
| **Input System** | 新输入系统 |
| **Cinemachine** | 智能相机系统 |
| **TextMeshPro** | 高质量文本渲染 |
| **ProBuilder** | 原型建模工具 |
| **ProGrids** | 网格对齐工具 |
| **2D Sprite Shape** | 2D 形状工具 |
| **Addressables** | 资源异步加载系统 |

---

## 学习资源

### 官方资源

- **Unity Learn**: https://learn.unity.com/
- **Unity Manual**: https://docs.unity3d.com/Manual/
- **Scripting API**: https://docs.unity3d.com/ScriptReference/
- **Unity Discussions**: https://discussions.unity.com/
- **Asset Store**: https://assetstore.unity.com/

### 推荐学习路径

1. **入门**: Unity Learn 的 "Unity Essentials" 路径
2. **脚本**: C# 基础 + Unity Scripting API
3. **进阶**: 特定领域深入学习（渲染、网络、AI）
4. **实践**: 参与游戏项目或 Game Jam

---

## 相关链接

- 官方文档主页: https://docs.unity3d.com/Manual/index.html
- 脚本 API: https://docs.unity3d.com/ScriptReference/
- Unity Learn: https://learn.unity.com/
- Unity 下载: https://unity.com/download
