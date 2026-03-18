# Unreal Engine 5.5 文档摘要

> Unreal Engine 5 核心技术学习
> 来源: https://docs.unrealengine.com/
> 获取日期: 2026-03-18

---

## 关键洞察

### Nanite 虚拟化几何系统

**核心概念**：Nanite 是 UE5 的虚拟化几何系统，能够渲染像素级细节的高保真几何体。

**技术特点**：
| 特性 | 说明 |
|------|------|
| **像素级精度** | 只渲染屏幕上可见的三角形 |
| **自动 LOD** | 智能简化几何体，无需手动创建 LOD |
| **无限多边形** | 突破传统多边形数量限制 |
| **内存虚拟化** | 按需加载几何数据 |

**支持的网格类型**：
- 静态网格（Static Meshes）
- 骨骼网格（Skeletal Meshes，有限支持）
- Landscape 地形
- 植被系统

**性能优势**：
- 显著降低内存占用
- 消除手动 LOD 制作工作流
- 支持电影级高精度资产直接使用

**限制**：
- 不支持透明材质
- 不支持世界位置偏移（World Position Offset）
- 需要兼容的渲染管线

---

### Lumen 全局光照系统

**核心概念**：Lumen 是 UE5 的全动态全局光照和反射系统。

**技术特性**：
| 功能 | 说明 |
|------|------|
| **实时 GI** | 无需预计算的全局光照 |
| **动态反射** | 实时屏幕空间和场景反射 |
| **自发光照明** | 材质自发光可照亮场景 |
| **天空光照** | 动态天空贡献计算 |

**渲染技术**：
1. **表面缓存（Surface Cache）**
   - 场景表面的光照缓存
   - 快速间接光照计算

2. **光线追踪（Ray Tracing）**
   - 硬件光线追踪支持
   - 高质量反射和阴影

3. **软件光线追踪**
   - 网格距离场
   - 无需 RTX 硬件

**性能考量**：
- 高质量模式需要 RTX 硬件
- 性能模式适用于更多平台
- 场景复杂度影响性能

**使用场景**：
- 室内场景动态光照
- 日夜循环系统
- 实时时间变化

---

### Virtual Shadow Maps (VSMs)

**核心概念**：VSMs 是 UE5 的高分辨率阴影贴图系统。

**技术规格**：
| 参数 | 值 |
|------|------|
| **分辨率** | 最高 16k x 16k |
| **缓存机制** | 逐光源缓存 |
| **过滤技术** | SMRT (Screen Space Shadow Ray Tracing) |

**核心优势**：
1. **统一阴影质量**
   - 所有光源一致的高质量阴影
   - 消除传统阴影贴图的伪影

2. **自动管理**
   - 无需手动调整阴影分辨率
   - 自动适应场景复杂度

3. **性能优化**
   - 智能缓存策略
   - 按需更新

**SMRT 技术**：
- 屏幕空间阴影光线追踪
- 提供柔和的半影效果
- 与 VSM 配合使用

**适用场景**：
- 大型开放世界
- 多光源场景
- 电影级阴影质量

---

### World Partition 世界分区

**核心概念**：World Partition 是 UE5 的大型世界管理和流式加载系统。

**系统架构**：
```
World Partition
├── 空间分区（Spatial Division）
│   └── 运行时单元格（Runtime Cells）
├── 数据层（Data Layers）
│   └── 数据组织和管理
└── HLOD 系统
    └── 层级细节优化
```

**核心功能**：

| 功能 | 说明 |
|------|------|
| **自动分区** | 基于网格的自动空间划分 |
| **距离流式加载** | 根据玩家距离加载/卸载 |
| **数据层** | 逻辑分组和运行时控制 |
| **HLOD 集成** | 远距离代理几何体 |

**One File Per Actor**：
- 每个 Actor 独立文件存储
- 支持 World Partition
- 优化团队协作
- 减少版本冲突

**配置选项**：
- 单元格大小可调
- 加载范围可配置
- 数据层运行时开关

**最佳实践**：
1. 合理设置单元格大小
2. 使用 HLOD 优化远景
3. 数据层分组策略规划
4. 预加载关键区域

---

### Blueprints 蓝图可视化脚本

**核心概念**：Blueprints 是 UE 的节点式可视化编程系统。

**蓝图类型**：
| 类型 | 用途 |
|------|------|
| **Level Blueprint** | 关卡特定逻辑 |
| **Class Blueprint** | 可复用的游戏对象类 |
| **Widget Blueprint** | UI 界面 |
| **Animation Blueprint** | 动画逻辑 |
| **Interface Blueprint** | 蓝图间通信接口 |

**核心节点类别**：
1. **流程控制**
   - Branch（条件分支）
   - For Loop（循环）
   - Sequence（顺序执行）
   - Delay（延迟）

2. **事件系统**
   - Event BeginPlay
   - Event Tick
   - 自定义事件
   - 输入事件

3. **数据操作**
   - 变量（Variables）
   - 数组（Arrays）
   - 集合（Sets）
   - 映射（Maps）

4. **通信方式**
   - 直接引用
   - 事件分发器
   - 蓝图接口
   - 消息系统

**蓝图 vs C++**：
| 方面 | Blueprint | C++ |
|------|-----------|-----|
| 开发速度 | 快 | 慢 |
| 执行性能 | 较低 | 高 |
| 调试体验 | 可视化 | 传统 |
| 团队协作 | 版本合并困难 | 标准 Git |
| 适用场景 | 原型/玩法逻辑 | 核心系统 |

**性能优化建议**：
- 避免在 Tick 中执行复杂逻辑
- 使用事件驱动替代轮询
- 数学密集型操作用 C++
- 合理使用 Delay 节点

---

## 核心指标

| 指标 | 值 | 说明 |
|------|------|------|
| VSM 最高分辨率 | 16k x 16k | 单个阴影贴图 |
| Nanite 三角形精度 | 像素级 | 屏幕空间 |
| Lumen GI 延迟 | 毫秒级 | 实时计算 |
| World Partition 单元格 | 可配置 | 默认 12800 单位 |

---

## 最佳实践

1. **Nanite 使用**：
   - 高模资产直接导入
   - 避免过度细分
   - 注意材质兼容性

2. **Lumen 优化**：
   - 根据平台选择质量模式
   - 合理设置自发光强度
   - 使用 Lumen 场景设置优化

3. **VSM 配置**：
   - 启用阴影缓存
   - 合理设置阴影距离
   - 配合级联阴影使用

4. **World Partition 规划**：
   - 提前规划数据层结构
   - 使用 HLOD 减少远景开销
   - 测试流式加载性能

5. **蓝图开发**：
   - 保持蓝图逻辑清晰
   - 使用函数和宏复用逻辑
   - 性能敏感部分用 C++ 重写

---

## 知识来源

| 来源 | URL | 日期 |
|------|-----|------|
| UE 5.5 Documentation | https://docs.unrealengine.com/ | 2026-03-18 |
| Nanite Documentation | https://docs.unrealengine.com/5.5/en-US/nanite-virtualized-geometry-in-unreal-engine/ | 2026-03-18 |
| Lumen Documentation | https://docs.unrealengine.com/5.5/en-US/lumen-global-illumination-and-reflections-in-unreal-engine/ | 2026-03-18 |
| Virtual Shadow Maps | https://docs.unrealengine.com/5.5/en-US/virtual-shadow-maps-in-unreal-engine/ | 2026-03-18 |
| World Partition | https://docs.unrealengine.com/5.5/en-US/world-partition-in-unreal-engine/ | 2026-03-18 |
| Blueprints | https://docs.unrealengine.com/5.5/en-US/blueprints-visual-scripting-in-unreal-engine/ | 2026-03-18 |

**总计**：6 个核心主题，约 35 个知识点
