---
name: docs-summary
description: 문서를 요약하여 Notion의 Docs Summary 페이지에 정리합니다. URL, PDF, docx, hwp, md 파일을 요약할 때 사용합니다.
argument-hint: "[URL 또는 파일경로]"
allowed-tools: Read, Bash, WebFetch, WebSearch, mcp__notion__API-post-page, mcp__notion__API-patch-block-children, mcp__notion__API-get-block-children, mcp__notion__API-retrieve-a-page
---

# 문서 요약 스킬

사용자가 전달한 문서(URL 또는 파일)를 읽고, 한국어로 요약하여 Notion "Docs Summary" 페이지의 하위 페이지로 저장합니다.

## 대상 Notion 페이지

- **페이지 이름**: Docs Summary
- **페이지 ID**: `3134b556-3d13-80e0-9ac8-ef4279a8b381`

## 처리 흐름

### 1단계: 문서 읽기

입력 유형에 따라 처리:

- **URL**: `WebFetch` 도구로 웹 페이지 내용을 가져온다
- **PDF 파일**: `Read` 도구로 읽는다 (pages 파라미터 활용)
- **md 파일**: `Read` 도구로 읽는다
- **docx 파일**: `Bash`에서 `pandoc` 등을 활용하여 텍스트를 추출한다
- **hwp 파일**: `Bash`에서 사용 가능한 변환 도구를 활용하여 텍스트를 추출한다

### 2단계: 요약 작성

아래 템플릿에 따라 **한국어**로 요약을 작성한다:

#### 요약 템플릿

```
## 개요
문서가 다루는 주제와 목적을 2~3문장으로 설명

## 핵심 포인트
- 문서에서 가장 중요한 내용을 bullet point로 정리
- 각 포인트는 1~2문장으로 구체적으로 서술
- 단순 키워드 나열이 아닌, 맥락을 포함한 설명

## 상세 내용
문서의 주요 내용을 섹션별로 정리한다.
각 섹션은 원문의 논리 흐름을 따르되, 불필요한 반복은 제거한다.
기술 문서의 경우 핵심 개념, 아키텍처, 사용법 등을 포함한다.
비기술 문서의 경우 주요 논점, 근거, 결론 등을 포함한다.

## 참고
- 원본 URL 또는 파일 경로
- 문서 작성일 (확인 가능한 경우)
- 관련 키워드/태그
```

### 3단계: Notion에 저장

1. `mcp__notion__API-post-page`를 사용하여 "Docs Summary" 페이지 하위에 새 페이지를 생성한다:
   - parent: `{ "page_id": "3134b556-3d13-80e0-9ac8-ef4279a8b381" }`
   - title: 문서 제목 (원문 제목 활용, 너무 길면 축약)
   - icon: 문서 유형에 따라 이모지 설정 (📄 일반문서, 🔗 웹페이지, 📊 기술문서)

2. `mcp__notion__API-patch-block-children`를 사용하여 요약 내용을 블록으로 추가한다:
   - heading_2 블록: 각 섹션 제목 (개요, 핵심 포인트, 상세 내용, 참고)
   - paragraph 블록: 본문 내용
   - bulleted_list_item 블록: bullet point 항목

## 주의사항

- 요약은 항상 **한국어**로 작성한다 (원문이 영어여도 한국어로 번역하여 요약)
- 원문의 핵심 의미를 왜곡하지 않도록 주의한다
- 너무 간략하게 축약하지 않는다. 읽는 사람이 원문을 보지 않아도 핵심 내용을 파악할 수 있을 정도로 작성한다
- Notion API의 rich_text content는 한 블록당 2000자 제한이 있으므로, 긴 내용은 여러 블록으로 나눈다
- 저장이 완료되면 Notion 페이지 URL을 사용자에게 알려준다
