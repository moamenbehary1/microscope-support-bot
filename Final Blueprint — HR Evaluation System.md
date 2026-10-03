# Final Blueprint — HR Evaluation System (Student Activity)

> الحالة: مسودة للاعتماد. لا يوجد كود. النقاط التي تحتاج قرارك مجمّعة في القسم 21.

---

## 1. Project Overview

**الهدف:** نظام ويب يقيّم به كل HR Member الأعضاء المسؤول عنهم خلال Evaluation Cycle يحددها الـ Admin، مع حساب تلقائي للدرجة والمستوى، وتاريخ تقييم ثابت لا يتأثر بتغيير الإعدادات، وتصدير لـ Google Sheets.

**المبادئ الحاكمة:**

1. **الصلاحيات تُطبَّق في الـ Backend وقواعد قاعدة البيانات**، وليس بإخفاء الشاشات.
2. **الحساب يتم Server-side** عند الـ Submit؛ الـ Client يعرض Preview فقط.
3. **Snapshot لكل الإعدادات** مع كل Cycle، وكل Evaluation تحمل قيمها النهائية داخلها.
4. **لا Hard Delete** لأي كيان (Disable / Inactive فقط).
5. **Google Sheets = Export فقط** وليس قاعدة بيانات.

---

## 2. User Roles & Permissions

| الدور | النطاق | ما يستطيعه | ما لا يستطيعه |
| --- | --- | --- | --- |
| **Super Admin** | كل شيء | كل الإدارة، إعادة فتح أي Evaluation، إدارة Codes والأدوار، Audit Log | — |
| **Head HR** (أكثر من واحد) | HRs التابعين له + أعضاؤهم | رؤية Evaluations والـ Analytics والـ Reports داخل نطاقه، إعادة فتح Evaluation داخل نطاقه، Export | تعديل Criteria/Rules/Levels، رؤية نطاق Head آخر |
| **HR Member** | الأعضاء المُسندون إليه فقط | إنشاء/حفظ/Submit تقييماته، رؤية تاريخ أعضائه (قراءة فقط)، طلب Reopen | أي إعدادات، Assignments، بيانات خارج نطاقه، Analytics عامة |
| **Member** | — | **لا يدخل النظام في V1**؛ هو كيان يُقيَّم فقط | — |

**قرار:** Head يقدر يقيّم بنفسه إذا أُسند له Members (يُعامل كـ HR + Head). موضح في القسم 21.

**التسلسل:** `Head → HRs → Members`. كل HR تابع لـ Head واحد، وكل Member لـ HR واحد.

---

## 3. Complete User Flow

**Admin (Setup مرة واحدة ثم عند التغيير):** Criteria → Bonus/Penalty Rules → Performance Levels → إضافة HRs وإصدار Codes → إضافة Members وتعيينهم لـ HRs.

**Admin (كل دورة):** إنشاء Cycle (Draft) ← نسخ الإعدادات الحالية داخلها وتعديلها لهذه الدورة إن لزم ← مراجعة ← **Activate** (هنا يحدث الـ Snapshot وتتجمد الإعدادات) ← متابعة التقدم ← Close بعد الـ Deadline ← Analytics / Reports / Export.

**HR:** Login بالـ Code ← Dashboard ← اختيار Member ← تعبئة التقييم ← Save Draft (متكرر) ← Submit قبل الـ Deadline.

**بعد Submit:** مقفول. التعديل فقط عبر Reopen (القسم 5).

---

## 4. Screen-by-Screen Flow

**مشتركة:** Login (Access Code) · Session expired.

**HR:**

1. **HR Dashboard:** الاسم، الـ Cycle الحالية، Deadline (عدّاد)، قائمة Members بحالة (Not Started / Draft / Submitted)، عدّادات Pending/Completed.
2. **Evaluation Screen:** بالترتيب: اسم Member ← كل Criterion (Rating أو Score + Auto Note) ← Bonus (اختيار Rules) ← Penalty ← Overall Note ← Summary (Criteria Total, Bonus, Penalty, Final, Level) ← Save Draft / Submit.
3. **Member History (قراءة فقط):** تقييمات سابقة وملاحظاتها لأعضائه.
4. **Reopen Request:** سبب + إرسال.

**Admin / Head:**

1. Dashboard
2. Members (قائمة، بحث، Profile، Active/Inactive)
3. HR Management (HRs، Codes، Head المسؤول)
4. Assignments (HR ← Members، نقل جماعي)
5. Cycles (قائمة، إنشاء، تفاصيل وتقدّم)
6. Criteria · Bonus Rules · Penalty Rules · Performance Levels (Super Admin فقط للتعديل)
7. Evaluations (قائمة بفلاتر + عرض كامل + Reopen)
8. Analytics & Averages
9. Reports
10. Export to Google Sheets
11. Reopen Requests
12. Audit Log (Super Admin)
13. Settings

---

## 5. Evaluation Logic

**الحالات:** Cycle: `Draft → Active → Closed`. Evaluation: `Not Started → Draft → Submitted` (+ `Reopened` بعد إعادة الفتح).

**إنشاء الـ Evaluations:** عند Activate، يولّد النظام Evaluation فارغة لكل Member Active، ويثبّت فيها `hrId`, `headId`, `committee`, واسم الـ Member وقتها. هذا يحل مشكلة تغيير الـ Assignment لاحقًا ويسهّل حساب Pending.

**شروط Submit:** كل Criteria مكتملة (إلا إذا سمحنا بـ N/A — قرار في القسم 21)، قبل الـ Deadline، وكل القيم داخل الحدود. التحقق والحساب في Cloud Function.

**تدفق التعديل بعد Submit (المقترح):**

- Submitted = **مقفولة** للـ HR.
- HR يرسل **Reopen Request** بسبب.
- Head (داخل نطاقه) أو Super Admin يوافق ← تتحول `Reopened` ويُحفظ نسخة من الحالة السابقة في `revisions`.
- HR يعدّل ويعيد Submit، وتُسجل في Audit Log.
- بعد **Close** للـ Cycle: Super Admin فقط يقدر يعيد الفتح.
- الـ Deadline يمكن تمديده من الـ Admin لكل Cycle أو لـ HR معين.

---

## 6. Criteria System

لكل Criterion: `name, description, mode (rating | direct), maxScore, active, order`.

**Rating Mode:** Rating 1–5، و**Mapping مخزّن صراحةً** (1→4 … 5→20) وليس معادلة، لأن الـ Admin يتحكم فيه. الافتراضي عند الإنشاء: خطي من الـ Max، ويمكن تعديله. لكل Rating Auto Note.

**Direct Mode:** HR يدخل رقمًا من 0 إلى Max (يُمنع الأكبر ويُرفض Server-side أيضًا). Auto Notes حسب Ranges.

**قواعد التحقق عند Activate Cycle:**

- مجموع Max لكل Criteria النشطة = **100** (أو نعتمد Normalization — قرار في 21).
- Ranges للـ Notes بدون فجوات أو تداخل.
- Mapping متزايد منطقيًا (تحذير فقط).

**الـ Auto Note** تُنسخ كنص داخل Evaluation وقت الحساب، فلا تتغير لاحقًا.

---

## 7. Bonus / Penalty Logic

كل Rule: `name, points (موجب للـ Bonus / سالب أو قيمة تُخصم للـ Penalty), active`، وإعدادات اختيارية:

- `allowMultiple` / `maxTimes` (هل تُطبَّق أكثر من مرة؟ مثل Late Task × 2).
- سقف إجمالي للـ Bonus و/أو Penalty لكل Evaluation (اختياري، افتراضيًا بلا سقف).

**HR يختار Rule فقط** ويمكنه كتابة سبب/تفصيلة اختيارية، لكن لا يكتب النقاط. النقاط تُنسخ من الـ Snapshot لـ Evaluation (اسم + قيمة + عدد مرات).

**Bonus مستقل تمامًا عن Performance Level** (كما حددت).

---

## 8. Performance Level Logic

**الصيغة:** `Final = Criteria Total + Bonus − Penalty`.

**اقتراحات لتجنب الغموض:**

- نخزّن كل Level بـ **حد أدنى (minScore)** فقط، والمستوى هو أعلى Level يحقق `Final ≥ minScore`. هذا يلغي الفجوات مثل 94.5 بين 94 و95.
- الافتراضي: 95 Outstanding · 85 Excellent · 75 Very Good · 65 Good · 50 Needs Improvement · 0 Critical.
- لكل Level: `name, minScore, finalNote, color`.
- **Final \< 0:** يُقصّ عند 0. **Final > 100:** مسموح أم مقصوص؟ — قرار في 21 (الافتراضي المقترح: مسموح ويُعرض كما هو).
- الـ Level **لا يضيف أي نقاط**.
- الـ Level والـ Final Note يُخزّنان داخل Evaluation كقيم نهائية.

---

## 9. Database Structure (Firestore)

> الحجم الحالي (مئات الأعضاء) مناسب جدًا لـ Firestore. Denormalization مقصودة.

| Collection | الحقول الأساسية |
| --- | --- |
| `users/{uid}` | name, role (`superAdmin/head/hr`), headId (للـ HR), active, createdAt, adminSystemRef |
| `accessCodes/{codeKey}` | userId, active, createdAt, rotatedAt, failedAttempts, lockedUntil — **الـ Client ممنوع منها بالكامل** |
| `members/{id}` | name, committee, assignedHrId, headId (مكرّر للـ Rules), active, createdAt, deactivatedAt |
| `criteria/{id}` | name, description, mode, maxScore, ratingMap, ratingNotes, rangeNotes, active, order |
| `bonusRules/{id}` · `penaltyRules/{id}` | name, points, allowMultiple, maxTimes, active |
| `settings/performanceLevels` | levels\[ {name, minScore, finalNote, color} \] |
| `cycles/{id}` | name, type, startDate, endDate, deadline, status, **configSnapshot** {criteria\[\], bonusRules\[\], penaltyRules\[\], levels\[\]}, snapshotAt, createdBy |
| `evaluations/{cycleId_memberId}` | cycleId, memberId, memberName, committee, hrId, headId, status, **criteriaResults\[** {criterionId, name, mode, max, rating?, score, autoNote} **\]**, bonusApplied\[ \], penaltyApplied\[ \], criteriaTotal, bonusTotal, penaltyTotal, finalScore, maxPossible, levelName, levelNote, overallNote, submittedAt, updatedAt, isLate, version |
| `evaluations/{id}/revisions/{n}` | نسخة كاملة قبل كل Reopen/تعديل + السبب + المسؤول |
| `reopenRequests/{id}` | evaluationId, requestedBy, reason, status, decidedBy, decidedAt |
| `auditLogs/{id}` | actorId, actorRole, action, entityType, entityId, before, after, timestamp |
| `exportJobs/{id}` | userId, scopeSummary, createdAt, sheetUrl, status (بدون أي Tokens) |

**ملاحظات تصميم:**

- `evaluations` تحمل كل القيم النهائية، فتبقى صحيحة حتى لو حُذف الـ Cycle أو تغيّرت الإعدادات.
- ID حتمي `cycleId_memberId` يمنع التكرار.
- فهارس Composite على: (hrId, cycleId, status)، (headId, cycleId)، (memberId, submittedAt)، (cycleId, status).

---

## 10. Authentication & Security

**Access Code Flow:**

1. المستخدم يدخل الـ Code.
2. Cloud Function `signInWithCode` تحسب **HMAC-SHA256 بـ Pepper سري (Secret Manager)** وتبحث عن النتيجة في `accessCodes`.
3. إذا صحيح وActive وغير مقفول ← تُصدر **Firebase Custom Token** بـ Claims بسيطة: `role` و`uid`.
4. الـ Client يسجّل دخول بالـ Token.

**لماذا HMAC بدل bcrypt؟** لأنه يسمح بالبحث المباشر بالـ Code دون تعريف المستخدم أولًا، ومع **Codes عشوائية عالية الإنتروبيا (12+ حرفًا)** يكون آمنًا. (البديل: Code = `UserID-Secret` ويُهَش الجزء السري بـ scrypt.)

**حماية إضافية:** Rate limiting وLockout تدريجي بعد المحاولات الفاشلة، Firebase **App Check**، Codes تُعرض مرة واحدة فقط عند الإنشاء، Reveal غير ممكن لاحقًا (Rotate فقط)، تغيير/تعطيل Code يعمل `revokeRefreshTokens`، وSession قصيرة نسبيًا مع Refresh.

**الصلاحيات:**

- **Firestore Rules:** قراءة فقط ضمن النطاق (HR: `hrId == uid`، Head: `headId == uid`، Super Admin: الكل). Collections الحساسة (`accessCodes`, `auditLogs`, `exportJobs`) مقفولة على الـ Client.
- **كل الكتابة الحساسة عبر Cloud Functions:** Submit، Reopen، Activate Cycle، Assignments، الأدوار، الـ Codes، الـ Export. الـ HR لا يكتب Final Score أبدًا.
- نطاق Head يُحسب من الـ Documents (`headId`) وليس من Claims، لأن القوائم قد تكبر وتتغير.

**Google OAuth Data:** Client Secret في Secret Manager فقط، ولا تُخزَّن Tokens في V1.

---

## 11. Google Sheets Integration Flow

1. المستخدم يضغط **Continue with Google** ويختار Export (Cycle / Scope).
2. الـ Client يحصل على **Authorization Code** من Google (Code Flow وليس Implicit).
3. يرسله لـ Cloud Function، التي تبدّله بـ Access Token باستخدام الـ Client Secret (Secret Manager).
4. الـ Function **تحدد البيانات المسموح بها من هوية المستخدم في النظام** (لا تثق بأي فلتر قادم من الـ Client).
5. تنشئ Spreadsheet **داخل Drive الخاص بالمستخدم**، وتكتب البيانات، وتعيد الرابط.
6. تُسجَّل العملية في `exportJobs` وAudit Log.

**قرارات:**

- **V1: بدون تخزين Refresh Token**؛ كل Export يطلب موافقة سريعة. أبسط وأكثر أمانًا.
- **Scope الأدنى** (غالبًا `drive.file`، وتُؤكَّد وقت التنفيذ) لتجنب مراجعة Google للـ Sensitive Scopes.
- تنبيه: قد تحجب بعض حسابات الجامعات/Workspace تطبيقات OAuth خارجية.
- **قابلية التوسع:** هيكل Export يعتمد على **Column Mapping** محفوظ (Collection `exportTemplates` في Phase 2) بدلًا من أعمدة مكتوبة صلبة.

---

## 12. Existing Admin System Integration

لم أفترض طريقة الربط. الخيارات:

| الخيار | الميزة | العيب |
| --- | --- | --- |
| **A.** HR Module داخل نفس Admin Dashboard | تجربة موحدة | يربط دورة التطوير والنشر والأخطاء بالنظامين؛ Auth الحالي قد لا يدعم Access Codes |
| **B.** مشروع Firebase منفصل تمامًا | عزل كامل | ازدواج المستخدمين، ربط صعب، تكلفة صيانة |
| **C.** نفس Firebase Project + **تطبيق Web مستقل** + Collections خاصة (`hr_*`/ما سبق) + ربط الهوية بـ `adminSystemRef` | عزل في الكود والـ Rules، بدون ازدواج بنية تحتية، روابط بين النظامين ممكنة | يحتاج انضباطًا في Rules |

**المقترح: C**، لأنه أقل تعقيدًا مع أمان جيد وقابلية للتوسع، ويمكن لاحقًا دمجه في الـ Dashboard (الخيار A) كـ Route مستقل أو Link. **شرط:** هذا مشروط بمعرفة تقنية الـ Admin الحالي (القسم 21، سؤال 1). إن كان على Firebase فـ C مناسب؛ وإن كان على Backend مختلف فنراجع (B مع Mapping للمستخدمين).

---

## 13. Dashboard Structure

**Admin/Head:** بطاقات: Total / Active / Inactive Members · Total HRs · Current Cycle · Evaluated · Pending · Progress % · Upcoming Deadline. تحتها: تقدّم كل HR (من أنهى كم)، وتنبيه لمن تجاوز Deadline. روابط: القسم 4. كل الأرقام **مقيّدة بنطاق Head**.

**HR:** كما في القسم 4، وبسيط عمدًا.

---

## 14. Analytics & Average

- **الـ Average = متوسط Final Score للتقييمات Submitted فقط**، مع إظهار عدد التقييمات بجانبه (مثال 91.33 من 3).
- لتجنب خلط مقاييس مختلفة نخزّن `maxPossible` ونقدر نحسب **Percentage** أيضًا.
- **الفلاتر:** Member · Committee · HR · Cycle · Date Range (كلها ضمن النطاق المسموح).
- **عروض:** متوسط الـ Committee، متوسط كل HR (مفيد لاكتشاف تشدد/تساهل HR)، توزيع الـ Levels، Trend للعضو، من لم يُقيَّم.
- **V1:** الحساب من استعلامات مباشرة (الحجم صغير). **Phase 2:** تجميعات مسبقة إذا كبر الحجم.
- HR لا يرى Analytics عامة؛ يرى فقط تاريخ أعضائه.

---

## 15. Reports

**محتوى Report العضو:** بياناته، الـ Cycle، Criteria Scores مع الملاحظات، Bonus، Penalty، Final، Level، Overall Note. **Report جماعي:** لمجموعة Members ضمن صلاحية المستخدم، بنفس البنية (صف لكل Member/Cycle). **V1:** عرض داخل النظام + Export إلى Google Sheets. **Phase 2:** PDF.

---

## 16. Audit Log

**يدخل MVP (نسخة خفيفة)** لأنه رخيص الآن ومكلف إضافته لاحقًا، ويحمي من الخلافات.

- يُكتب **من Cloud Functions فقط**، Append-only، ولا يُعدَّل ولا يُحذف.
- الأحداث: Criteria/Rules/Levels · Assignments · Roles · Codes (**بدون قيم الـ Codes**) · Activate/Close Cycle · Reopen/تعديل Evaluation · Export.
- الحقول: من، متى، ماذا، قبل/بعد.
- **Phase 2:** واجهة بحث وفلاتر متقدمة وتصدير.

---

## 17. MVP Scope

1. Access Code Auth + الأدوار الثلاثة (Super Admin / Head / HR)
2. Members (بدون Delete) + Assignments + HR Management
3. Criteria (Rating + Direct) مع Notes
4. Bonus/Penalty Rules + Performance Levels
5. Cycles مع **Snapshot** ومنطق Activate/Close
6. Evaluation (Draft / Submit) + حساب Server-side
7. Reopen flow
8. Dashboards (Admin/Head/HR)
9. Member History
10. Analytics أساسية (Average + فلاتر)
11. Report + Google Sheets Export (بدون Templates)
12. Audit Log خفيف
13. Firestore Rules + اختبارات الصلاحيات
14. واجهة عربية RTL (إن كانت المطلوبة)

---

## 18. Phase 2 Features

Export Templates/Column Mapping · PDF Reports · تخزين Refresh Token للـ Export المتكرر · Audit Log UI · Analytics مجمّعة مسبقًا · Notifications/تذكير بالـ Deadline · Bulk Import للـ Members (CSV) · قواعد خاصة بالـ Inactive/المحذوفين · Member Portal (لو احتجت) · تقييم HR نفسه · Weighted Criteria · Dark Mode · Multi-language.

---

## 19. Recommended Technology Stack

| الطبقة | القرار |
| --- | --- |
| Frontend | **Flutter Web** مناسب (لوحة داخلية، لا SEO). Next.js يُفضَّل فقط لو فريقك أقوى في React أو لو الـ Admin الحالي React |
| Backend | **Cloud Functions (2nd gen)** |
| Database | **Firestore** (حجم صغير، Realtime مفيد للـ Drafts، Rules للصلاحيات) |
| Auth | Custom Access Code ← Firebase Custom Token |
| Security إضافي | App Check + Secret Manager |
| Google | Sheets/Drive API + OAuth 2.0 (Code Flow من الـ Backend) |
| State Management | يُحسم في مرحلته (المرشح: Riverpod) |
| Hosting | Firebase Hosting |

**سبب عدم تغيير الـ Stack:** لا يوجد سبب قوي. نقطة ضعف Firestore الوحيدة هي التقارير العلائقية المعقدة، وحجمك لا يحتاجها. إن احتجنا لاحقًا نضيف BigQuery Export.

---

## 20. Important Edge Cases

1. **تغيير Assignment أثناء Cycle:** Evaluation تحتفظ بـ HR وقت التفعيل؛ النقل يمرّ بقرار: هل ينتقل التقييم غير المكتمل للـ HR الجديد؟ (افتراضيًا نعم للـ Draft/Not Started، لا للـ Submitted).
2. **Member جديد أثناء Cycle:** إجراء "Add to active cycle" يدويًا.
3. **Member يصبح Inactive أثناء Cycle:** يظل تقييمه المُنجز، ويُستبعد غير المكتمل بقرار Admin.
4. **HR يصبح Inactive:** تُعاد أعضاؤه لـ HR آخر قبل التعطيل (يمنعه النظام وإلا).
5. **تعطيل Criterion/Rule في وسط Cycle:** لا أثر (Snapshot).
6. **تعديل نفس Evaluation من جهازين:** Optimistic concurrency بحقل `version`.
7. **تجاوز Deadline وهو Draft:** لا Submit إلا بتمديد من الـ Admin.
8. **Final > 100 أو \< 0.**
9. **Rating Mapping أو Range فيه فجوة:** يُمنع Activate.
10. **تغيير Code أثناء Session:** إلغاء الجلسات.
11. **Cycles متداخلة التواريخ:** مسموح أم لا؟ (21).
12. **Rule مُطبّقة ثم Disabled:** تظل في الـ Evaluation القديمة.
13. **تكرار Evaluation لنفس Member/Cycle:** مستحيل بالـ ID الحتمي.
14. **فشل منتصف Export:** Job بحالة Failed وإمكانية الإعادة.
15. **HR يرى ملاحظات سابقة كتبها HR آخر عن عضو نُقل إليه:** قرار في 21.

---

## 21. Questions / Decisions Still Needed

**تعارضات/نقاط ناقصة اكتشفتها:**

1. **الـ Admin System الحالي:** على أي تقنية؟ (Firebase؟ Auth بأي طريقة؟ Flutter أم React؟) — يحدد القسم 12.
2. **مجموع الـ Criteria = 100؟** الـ Levels مبنية على 100. هل نُلزم المجموع بـ 100 أم نعمل Percentage؟
3. **Final Score فوق 100 بسبب Bonus:** مسموح أم مقصوص؟
4. **Penalty:** هل قد يجعل الدرجة سالبة؟ (المقترح: Floor عند 0).
5. **Head يقيّم بنفسه؟** وهل HR يتبع Head واحد دائمًا؟
6. **Cycle تشمل كل الأعضاء أم Committees معينة؟**
7. **هل الـ HR يعدّل الـ Auto Note أم تبقى كما هي مع Overall Note فقط؟**
8. **هل يسمح بـ N/A لـ Criterion** (مثل عضو جديد لا Attendance له)؟
9. **الدرجات العشرية في Direct Mode** مسموحة؟
10. **هل HR يرى ملاحظات HR سابق عن نفس العضو؟**
11. **تداخل الـ Cycles** (Weekly + Monthly معًا)؟ وهل التقييمات الأسبوعية تدخل متوسطات الشهرية؟
12. **لغة الواجهة والملاحظات:** عربي RTL فقط أم ثنائي؟
13. **Super Admin:** كم شخص؟ وهل نحتاج حماية إضافية (مثل Code أقوى أو تأكيد للعمليات الحساسة)؟
14. **حسابات Google** المتوقعة: Gmail عادي أم Workspace الجامعة (قد تحجب OAuth)؟

---

## 22. Final Architecture Diagram (Text)

```
┌──────────────────────────────────────────────────────────┐
│                Flutter Web App (HR System)               │
│  Login │ HR Dashboard │ Evaluation │ Admin/Head Panels   │
└───────────────┬───────────────────────────┬──────────────┘
                │ Firebase Auth (Custom     │ Read (scoped by
                │ Token)                    │ Firestore Rules)
                ▼                           ▼
┌──────────────────────────┐   ┌───────────────────────────┐
│ Cloud Functions (2nd gen)│──▶│ Cloud Firestore           │
│ • signInWithCode         │   │ users, members, criteria, │
│ • activateCycle(snapshot)│   │ rules, cycles(+snapshot), │
│ • submitEvaluation(calc) │   │ evaluations(+revisions),  │
│ • reopen / assignments   │   │ auditLogs, exportJobs     │
│ • manageCodes / roles    │   │ accessCodes (server only) │
│ • exportToSheets         │   └───────────────────────────┘
└──────┬──────────┬────────┘
       │          │
       ▼          ▼
┌────────────┐  ┌──────────────────────────────────────┐
│ Secret     │  │ Google OAuth 2.0 → Sheets/Drive API  │
│ Manager    │  │ Sheet created in the USER's own Drive│
│ (Pepper,   │  └──────────────────────────────────────┘
│ Client     │
│ Secret)    │      ┌───────────────────────────────┐
└────────────┘      │ Existing Admin System         │
                    │ (same Firebase project +      │
                    │ adminSystemRef mapping)       │
                    └───────────────────────────────┘
```

**الخطوة التالية بعد اعتماد البلوبرنت:** UI Design ← Database (Rules + Indexes) ← Backend ← Authentication ← State Management ← Google Sheets ← Testing ← Deployment.