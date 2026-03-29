# PRD - AI Fabric Product Description & SEO Generator

## 1. Overview

Hệ thống AI hỗ trợ tự động tạo nội dung mô tả sản phẩm và SEO cho các sản phẩm vải (fabric) nhằm:
- Tăng tốc độ đăng sản phẩm
- Chuẩn hóa nội dung
- Tối ưu SEO
- Tăng tỉ lệ chuyển đổi

Hệ thống bao gồm:
- Backend (API + AI + Database)
- Frontend (hiển thị sản phẩm)

---

## 2. Goals

### Business Goals
- Giảm 80% thời gian viết mô tả sản phẩm
- Tăng chất lượng nội dung SEO
- Tăng conversion rate

### User Goals
- Nhập thông tin vải nhanh
- Nhận nội dung sẵn sàng đăng bán
- Dễ chỉnh sửa & lưu trữ

---

## 3. Target Users

- Chủ shop bán vải (online)
- Nhân viên đăng sản phẩm
- Marketer SEO

---

## 4. Features

### 4.1 Backend - AI Generator

#### Input:
- Tên vải (Fabric Name)
- Đặc điểm (Features)
  - chất liệu (cotton, linen…)
  - độ bền
  - khả năng chống nước
  - phù hợp (sofa, rèm…)

#### Output (AI generate):
- Product Description (mô tả hấp dẫn)
- SEO Title
- Bullet Points (3–5 điểm nổi bật)
- (Optional) Meta Description

---

### 4.2 Database

#### Product Table:
- id
- name
- features (text/json)
- description
- seo_title
- bullet_points
- created_at

---

### 4.3 Frontend - Product Page

Hiển thị:
- Tên sản phẩm
- SEO title
- Mô tả
- Bullet points

Optional:
- Search sản phẩm
- Filter theo loại vải

---

## 5. User Flow

### Admin Flow (Backend)
1. Nhập tên vải + đặc điểm
2. Click "Generate"
3. AI trả về nội dung
4. Chỉnh sửa (optional)
5. Lưu vào database

### Customer Flow (Frontend)
1. Truy cập website
2. Xem danh sách sản phẩm
3. Click vào sản phẩm
4. Xem mô tả + bullet points
5. Quyết định mua

---

## 6. AI Prompt Design

You are a fabric expert and SEO copywriter.

Generate:
1. A compelling product description
2. An SEO-optimized title
3. 3–5 bullet points

Input:
- Fabric name: {{name}}
- Features: {{features}}

Requirements:
- Focus on benefits, not just features
- Easy to read
- Persuasive tone
- SEO-friendly keywords

---

## 7. Tech Stack

### Backend
- Node.js / Python (FastAPI)
- OpenAI API / Gemini API
- Database: PostgreSQL / MongoDB

### Frontend
- Next.js / React
- Tailwind CSS

---

## 8. API Design

### POST /generate

Request:
{
  "name": "Linen Fabric",
  "features": "breathable, durable, soft"
}

Response:
{
  "description": "...",
  "seo_title": "...",
  "bullet_points": ["...", "..."]
}

---

### POST /save-product

### GET /products

### GET /products/:id

---

## 9. Success Metrics

- Time to create product ↓
- Organic traffic ↑
- Conversion rate ↑

---

## 10. Future Improvements

- Auto keyword research
- Image-based fabric recognition
- AI chatbot tư vấn chọn vải
- Tự động đăng lên Shopify / website

---

## 11. Risks

- Nội dung AI trùng lặp
- SEO chưa tối ưu đúng thị trường US
- Người dùng cần chỉnh sửa lại

---

## 12. Notes

- Luôn ưu tiên:
  - Dễ đọc
  - Thực tế
  - Tập trung lợi ích khách hàng

- Tránh:
  - Nội dung chung chung
  - Quá kỹ thuật
