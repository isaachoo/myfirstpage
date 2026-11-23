# 李節街宿舍（Li Chit Street Hostel）網站改版 — Concept Preview

靜態網站設計示範（Traditional Chinese），**不是聖雅各福群會正式網站**。

## 查看畫面

- 預覽連結（由第三方 raw.githack.com 根據公開 GitHub 檔案呈現）：https://raw.githack.com/isaachoo/myfirstpage/lch-redesign-2026/lch-redesign/index.html
- 程式碼：`lch-redesign/index.html`
- 現行網站：https://lch.sjs.org.hk/

## 技術

- 單一 HTML 檔，CSS/JavaScript inline
- 不依賴 WordPress、PHP、Node.js、資料庫或第三方 JS CDN
- 響應式版型、手機導覽、常見問題展開、電話和地圖連結
- 概念插畫取代未經授權的宿舍實景相片
- 無表單、登入、Cookies 或追蹤程式碼

## 正式部署之前

1. 請服務單位核對內容、收費、電話、地址、申請資格及其他細節。
2. 取得機構授權，使用官方標誌及品牌指引（目前為概念視覺）。
3. 在受控環境測試無障礙、跨瀏覽器、網站監控及安全標頭。
4. 改用機構控制的正式靜態網站託管（如 GitHub Pages 或 Cloudflare Pages），設好 HTTPS 和網域。
5. 完成舊網站的檔案/內容/SEO 遷移及風險管控後，再進行 DNS 切換。

## GitHub Pages

此版本存於 `lch-redesign-2026` 分支下的 `lch-redesign/` 目錄。
如想用 GitHub Pages，於儲存庫 **Settings → Pages** 選擇 `Deploy from a branch`，來源選 `lch-redesign-2026` / `/(root)`，儲存後可透過 GitHub Pages 網址下的 `/lch-redesign/` 存取。此設定需由有權限的人手動啟用。

本專案僅作初步設計評估，不代表正式推出。
