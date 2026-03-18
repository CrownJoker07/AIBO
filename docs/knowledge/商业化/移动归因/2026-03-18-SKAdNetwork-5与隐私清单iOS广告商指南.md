# SKAdNetwork 5与隐私清单: iOS广告商2023最大变化

> 移动广告ROI与归因分析核心知识点
> 来源: https://tenjin.com/blog/two-biggest-changes-for-ios-advertisers-in-2023-skadnetwork-5-and-privacy-manifest/
> 获取日期: 2026-03-18

---

## 概述

2023年iOS广告商面临两大重大变化：SKAdNetwork 5和隐私清单。这些变化深刻影响了iOS广告归因和用户获取策略。

---

## SKAdNetwork 5 核心变化

### 版本演进
| 版本 | 发布时间 | 核心特性 |
|------|----------|----------|
| SKAdNetwork 2.0 | 2018 | 基础归因 |
| SKAdNetwork 3.0 | 2021 | 隐私阈值、层级转换值 |
| SKAdNetwork 4.0 | 2022 | 多层转换值、Web-to-App |
| **SKAdNetwork 5.0** | **2023** | **增强归因、更长窗口** |

### SKAdNetwork 5 关键更新

| 更新项 | 描述 | 影响 |
|--------|------|------|
| **扩展归因窗口** | 更长的归因时间窗口 | 提高归因准确性 |
| **增强层级** | 更多层级信息 | 更细粒度的广告组洞察 |
| **Web-to-App增强** | 改进Web到App归因 | 更好追踪跨平台转化 |

---

## 隐私清单 (Privacy Manifest)

### 什么是隐私清单?
- Apple要求的隐私数据使用声明
- 开发者必须明确说明使用了哪些隐私API
- 影响2024年后的App Store审核

### 核心要求
| 要求 | 描述 | 合规动作 |
|------|------|----------|
| **隐私API声明** | 声明使用的隐私相关API | 更新Info.plist |
| **数据使用说明** | 解释为何需要这些数据 | 提供清晰理由 |
| **第三方SDK合规** | 确保所有SDK也合规 | 审核SDK供应商 |

### 常见隐私API
| API类型 | 用途 | 注意事项 |
|---------|------|----------|
| **IDFA** | 广告追踪 | 需用户授权 |
| **IDFV** | 供应商内追踪 | 无需授权 |
| **磁盘空间** | 设备指纹风险 | 需要正当理由 |
| **系统启动时间** | 设备指纹风险 | 需要正当理由 |

---

## 对广告商的影响

### 归因变化
```
SKAdNetwork 5归因流程:
1. 用户点击广告
2. 安装应用
3. 等待转换窗口(最长可达数周)
4. 接收聚合归因数据(非用户级)
```

### 策略调整
| 策略 | 变化前 | 变化后 |
|------|--------|--------|
| **优化周期** | 实时 | 延迟聚合 |
| **数据粒度** | 用户级 | 聚合级 |
| **决策依据** | 确定性归因 | 建模归因 |

---

## 合规行动清单

### 即时行动
- [ ] 审核所有SDK的隐私清单合规性
- [ ] 更新App的隐私声明
- [ ] 测试SKAdNetwork 5集成

### 短期行动
- [ ] 调整UA策略适应延迟数据
- [ ] 建立建模归因能力
- [ ] 培训团队理解新归因逻辑

### 长期行动
- [ ] 投资隐私安全的数据基础设施
- [ ] 建立混合归因框架
- [ ] 持续关注Apple政策变化

---

## 技术实施要点

### SKAdNetwork 5 集成
```
// 注册SKAdNetwork
[SKAdNetwork registerAppForAdNetworkAttribution];

// 更新转换值
[SKAdNetwork updateConversionValue:conversionValue];
```

### 隐私清单配置
```xml
<key>NSPrivacyTracking</key>
<true/>
<key>NSPrivacyTrackingDomains</key>
<array>
    <string>example.com</string>
</array>
<key>NSPrivacyCollectedDataTypes</key>
<array>
    <!-- 数据类型声明 -->
</array>
<key>NSPrivacyAccessedAPITypes</key>
<array>
    <!-- API类型声明 -->
</array>
```

---

## 行动建议

1. **立即审计**: 检查所有SDK的隐私清单合规状态
2. **更新集成**: 确保SKAdNetwork 5正确集成
3. **调整策略**: 适应延迟聚合数据的新常态
4. **建立建模能力**: 投资混合归因技术
5. **持续关注**: 密切关注Apple政策更新

---

## 相关文档

- [高级移动测量Meta集成](./2026-03-18-高级移动测量Meta集成.md)
- [TikTok实时转化报告iOS](./2026-03-18-TikTok实时转化报告iOS.md)
- [统一测量框架-归因修复指南](./2026-03-18-统一测量框架-归因修复指南.md)

---

## 来源追踪

| 字段 | 值 |
|------|-----|
| 文章URL | https://tenjin.com/blog/two-biggest-changes-for-ios-advertisers-in-2023-skadnetwork-5-and-privacy-manifest/ |
| 博客主页 | https://www.tenjin.com/blog/ |
| 获取日期 | 2026-03-18 |
| 分类 | 商业化/移动归因 |
