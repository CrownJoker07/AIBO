# Catlike Coding Unity 高级教程

> 数学、渲染与算法深度解析
> 来源: https://catlikecoding.com/unity/tutorials/
> 获取日期: 2026-03-18

---

## 概述

Catlike Coding 是由 Jasper Flick 创建的高质量 Unity 教程系列，专注于数学、渲染和算法的深度讲解。教程从基础概念到高级实现，涵盖完整的游戏开发技术栈。

---

## 教程系列索引

| 系列 | 主题 | 难度 |
|------|------|------|
| **Rendering** | 渲染管线、着色器编程 | 高级 |
| **Pseudorandom Noise** | 噪声生成算法 | 中级-高级 |
| **Hex Map** | 六边形地图系统 | 中级-高级 |
| **Object Management** | 对象管理、持久化 | 中级 |
| **Mesh Basics** | 网格基础 | 初级-中级 |
| **Procedural Meshes** | 程序化网格生成 | 中级-高级 |
| **Flow** | 流体模拟 | 中级 |
| **Marching Squares** | 等值线提取 | 中级 |
| **SRP (Custom Render Pipeline)** | 自定义渲染管线 Unity 2022 | 高级 |
| **Basics** | Unity 基础 | 初级 |
| **Clock** | 简单时钟应用 | 初级 |
| **Graph** | 函数可视化 | 初级 |
| **Fractals** | 分形生成 | 中级 |
| **Loops** | 循环结构 | 初级 |
| **Terrain** | 地形系统 | 中级 |

---

## 核心知识点

### 一、变换矩阵 (Transformation Matrices)

#### 1. 齐次坐标 (Homogeneous Coordinates)

**概念**：4D 点 `(x, y, z, w)` 用于 3D 变换
- `w = 1`：标准 3D 点
- `w = 0`：方向向量（不受平移影响）

**矩阵形式**：
```
| 1  0  0  tx |
| 0  1  0  ty |
| 0  0  1  tz |
| 0  0  0  1  |
```

#### 2. 旋转矩阵组合

绕 XYZ 三轴旋转的组合矩阵：

```csharp
// X 轴旋转角度 α，Y 轴旋转角度 β，Z 轴旋转角度 γ
float cosX = cos(α), sinX = sin(α);
float cosY = cos(β), sinY = sin(β);
float cosZ = cos(γ), sinZ = sin(γ);

Vector3 xAxis = new Vector3(
    cosY * cosZ,
    cosX * sinZ + sinX * sinY * cosZ,
    sinX * sinZ - cosX * sinY * cosZ
);
Vector3 yAxis = new Vector3(
    -cosY * sinZ,
    cosX * cosZ - sinX * sinY * sinZ,
    sinX * cosZ + cosX * sinY * sinZ
);
Vector3 zAxis = new Vector3(
    sinY,
    -sinX * cosY,
    cosX * cosY
);
```

#### 3. Unity 内置矩阵

| 矩阵 | 用途 |
|------|------|
| `unity_ObjectToWorld` | 模型空间 → 世界空间 |
| `unity_WorldToObject` | 世界空间 → 模型空间 |
| `UNITY_MATRIX_V` | 世界空间 → 视图空间 |
| `UNITY_MATRIX_P` | 视图空间 → 裁剪空间 |
| `UNITY_MATRIX_VP` | 世界空间 → 裁剪空间 |
| `UNITY_MATRIX_MVP` | 模型空间 → 裁剪空间（已弃用） |
| `UNITY_MATRIX_T_MV` | MV 矩阵转置 |
| `UNITY_MATRIX_IT_MV` | MV 矩阵逆转置（用于法线变换） |

---

### 二、着色器编程 (Shader Programming)

#### 1. 基础着色器结构

```hlsl
Shader "Custom/My First Shader" {
    Properties {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram
            #include "UnityCG.cginc"

            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;  // Tiling & Offset

            struct VertexData {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators MyVertexProgram (VertexData v) {
                Interpolators i;
                i.position = mul(UNITY_MATRIX_MVP, v.position);
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return i;
            }

            float4 MyFragmentProgram (Interpolators i) : SV_TARGET {
                return tex2D(_MainTex, i.uv) * _Tint;
            }
            ENDCG
        }
    }
}
```

#### 2. 纹理坐标变换

**TRANSFORM_TEX 宏**：
```hlsl
// 等价于：
i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
// _MainTex_ST.xy = Tiling (缩放)
// _MainTex_ST.zw = Offset (偏移)
```

#### 3. 纹理过滤模式

| 模式 | 特点 | 适用场景 |
|------|------|----------|
| **Point** | 像素化、锐利边缘 | 像素艺术 |
| **Bilinear** | 平滑插值 | 2D 游戏 |
| **Trilinear** | Mipmap 间插值 | 3D 场景 |
| **Anisotropic** | 斜角清晰 | 地面纹理 |

#### 4. Mipmap 层级

- 自动生成：每层是上一层的一半分辨率
- 优点：减少远处纹理闪烁（moiré pattern）
- 缺点：增加约 33% 内存占用

---

### 三、投影矩阵 (Projection Matrices)

#### 1. 正交投影 (Orthographic)

```csharp
// 无透视，平行投影
Matrix4x4 ortho = Matrix4x4.Ortho(size, aspect, near, far);
```

**特点**：
- 无透视畸变
- 适合 2D 游戏、UI、等距视角

#### 2. 透视投影 (Perspective)

```csharp
Matrix4x4 perspective = Matrix4x4.Perspective(fov, aspect, near, far);
```

**透视除法**：裁剪空间 `w` 分量 = 视图空间 `z` 分量（深度）

---

### 四、六边形网格系统 (Hexagonal Grid)

#### 1. 坐标系统

- **Offset 坐标**：行列索引，奇偶行错位
- **Cube 坐标**：(x, y, z) 满足 x + y + z = 0
- **Axial 坐标**：省略 y，用 (q, r) 表示

#### 2. 六边形尺寸

```
外径 (outer radius) = 外接圆半径
内径 (inner radius) = 内切圆半径 = outer * 0.8660254 (√3/2)
```

#### 3. 网格布局

```csharp
// 点尖朝上 (Pointy-top)
float x = (col + row * 0.5f) * (innerRadius * 2f);
float z = row * (outerRadius * 1.5f);

// 平边朝上 (Flat-top)
float x = col * (outerRadius * 1.5f);
float z = (row + col * 0.5f) * (innerRadius * 2f);
```

---

### 五、噪声生成算法 (Pseudorandom Noise)

#### 1. Value Noise

- 基于网格点的随机值
- 简单但有明显网格感

#### 2. Perlin Noise

- 梯度插值
- 自然、连续的变化
- 经典程序化地形生成

#### 3. Simplex Noise

- Perlin 的改进版
- 使用单纯形网格
- 更少方向性伪影，更高维度效率

#### 4. Worley Noise / Cellular Noise

- 基于最近点距离
- 产生细胞状图案
- 适合水面、石材纹理

---

### 六、自定义渲染管线 (Custom SRP)

#### 1. 渲染管线架构

```csharp
public class CustomRenderPipeline : RenderPipeline {
    protected override void Render(ScriptableRenderContext context, Camera[] cameras) {
        foreach (var camera in cameras) {
            RenderSingleCamera(context, camera);
        }
    }

    void RenderSingleCamera(ScriptableRenderContext context, Camera camera) {
        // 1. 设置相机参数
        context.SetupCameraProperties(camera);

        // 2. 剔除
        camera.TryGetCullingParameters(out var cullingParams);
        var cullingResults = context.Cull(ref cullingParams);

        // 3. 绘制不透明物体
        var drawingSettings = new DrawingSettings(...);
        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

        // 4. 绘制天空盒
        context.DrawSkybox(camera);

        // 5. 绘制透明物体
        filteringSettings = new FilteringSettings(RenderQueueRange.transparent);
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

        // 6. 提交
        context.Submit();
    }
}
```

#### 2. 渲染顺序

| 阶段 | 说明 |
|------|------|
| **Opaque** | 不透明物体（前到后排序） |
| **Skybox** | 天空盒 |
| **Transparent** | 透明物体（后到前排序） |

---

### 七、程序化网格生成 (Procedural Meshes)

#### 1. 网格组件

```csharp
Mesh mesh = new Mesh();
mesh.vertices = vertices;      // 顶点位置
mesh.triangles = triangles;    // 三角形索引
mesh.normals = normals;        // 法线
mesh.uv = uvs;                 // UV 坐标
mesh.tangents = tangents;      // 切线（用于法线贴图）
```

#### 2. 法线计算

```csharp
// 三角形法线 = 两条边的叉积
Vector3 normal = Vector3.Cross(b - a, c - a).normalized;
```

#### 3. RecalculateNormals 原理

- 对每个顶点，累加所有相邻三角形法线
- 归一化得到顶点法线

---

## 关键代码模式

### 1. 结构化缓冲区 (Structured Buffer)

```hlsl
StructuredBuffer<float3> _Positions;

[numthreads(64,1,1)]
void MyKernel (uint3 id : SV_DispatchThreadID) {
    float3 position = _Positions[id.x];
    // ...
}
```

### 2. GPU Instancing

```hlsl
UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_INSTANCING_BUFFER_END(Props)

float4 color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
```

### 3. 深度纹理采样

```hlsl
// 需要在 C# 中设置：camera.depthTextureMode = DepthTextureMode.Depth;
float depth = tex2D(_CameraDepthTexture, uv).r;
float linearDepth = LinearEyeDepth(depth, _ZBufferParams);
```

---

## 最佳实践

### 性能优化

1. **GPU Instancing**：相同材质多个物体使用实例化
2. **LOD**：根据距离使用不同细节级别
3. **遮挡剔除**：不渲染被遮挡物体
4. **批处理**：静态批处理、动态批处理

### 着色器开发

1. 使用 `UNITY_BRANCH` / `UNITY_FLATTEN` 控制分支
2. 避免在片段着色器中使用 `discard`（影响性能）
3. 使用 `saturate()` 代替 `clamp(x, 0, 1)`
4. 法线贴图使用切线空间

### 数学技巧

1. **快速平方根倒数**：Unity 内置 `rsqrt()`
2. **快速近似函数**：`FastInvSqrt()`、`FastPow()`
3. **避免三角函数**：预计算或使用查找表

---

## 知识关联

- [[游戏编程模式]] - 渲染循环、对象池
- [[Unity 6 文档摘要]] - URP、渲染管线
- [[设计模式指南]] - 工厂模式（网格生成）

---

## 参考资源

- 官方教程: https://catlikecoding.com/unity/tutorials/
- 作者: Jasper Flick
- 许可: CC BY-NC-SA 4.0
