# Ai2: Building Physical AI with Virtual Simulation Data

## 元数据
- **来源**: https://www.artificialintelligence-news.com/news/ai2-building-physical-ai-with-virtual-simulation-data/
- **发布日期**: 2026-03-11
- **获取日期**: 2026-03-17
- **分类**: Physical AI / Computer Vision / Open-Source
- **作者**: Ryan Daws

## 摘要
Allen Institute for AI (Ai2) 推出 MolmoBot，一个完全基于合成数据训练的开放式机器人操控模型套件，通过虚拟仿真数据驱动物理 AI 发展，显著降低机器人训练成本。

## 关键知识点

### 核心创新
- **MolmoBot**: 开放式机器人操控模型套件，完全基于合成信息训练
- **MolmoSpaces**: 程序化生成轨迹的系统，绕过人工远程操作需求
- **MolmoBot-Data**: 包含 180 万条专家操控轨迹的数据集

### 技术特点
- 结合 MuJoCo 物理引擎与激进的域随机化
- 变化对象、视角、照明和动力学参数
- 使用 100 块 Nvidia A100 GPU，每 GPU 小时生成约 1,024 个片段
- 每小时实际时间产生超过 130 小时的机器人经验

### 性能表现
- 桌面拾取放置任务成功率: 79.2%
- 超越使用大量真实世界数据训练的 π0.5 模型（39.2% 成功率）
- 零样本迁移到未见物体和环境的真实任务

### 三种策略类别
1. **MolmoBot 主模型**: 基于 Molmo2 视觉语言骨干
2. **MolmoBot-SPOC**: 轻量级 Transformer 策略，适用于边缘计算
3. **MolmoBot-Pi0**: 使用 PaliGemma 骨干，匹配 Physical Intelligence 的 π0 架构

### 硬件平台
- Rainbow Robotics RB-Y1 移动操作器
- Franka FR3 桌面机械臂

### 行业意义
- 打破对昂贵人工数据收集的依赖
- 将机器人约束从收集手动演示转移到设计更好的虚拟世界
- 数据吞吐量比真实世界收集高出约 4 倍

## 关键引用
> "Most approaches try to close the sim-to-real gap by adding more real-world data. We took the opposite bet: that the gap shrinks when you dramatically expand the diversity of simulated environments, objects, and camera conditions."
> — Ranjay Krishna, Director of the PRIOR team at Ai2

> "For AI to truly advance science, progress cannot depend on closed data or isolated systems. It requires shared infrastructure that researchers everywhere can build on, test, and improve together."
> — Ali Farhadi, CEO of Ai2

## 相关背景
- Google DeepMind RT-1: 17 个月收集 130,000 个片段
- DROID 项目: 13 个机构收集 76,000 条远程操作轨迹，约 350 小时人工努力

## 商业启示
- 降低机器人 AI 研发预算门槛
- 促进 AI 能力民主化
- 加速部署周期，提升项目投资回报率
- 开源发布完整堆栈支持内部审计和适配
