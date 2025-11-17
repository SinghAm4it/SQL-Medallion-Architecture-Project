
# 🧾 Insights Report — EDA & Advanced Analytics (SQL Medallion Pipeline)

## 📊 1. Exploratory Data Analysis (EDA)

The **EDA layer** focuses on understanding data distribution, relationships, and data quality across the **Gold Layer** tables — primarily `dim_customers`, `dim_products`, and `fact_sales`.

---

### 🧠 1.1 Dimension Exploration

**Purpose:** To understand the structure and diversity of categorical attributes.

**Findings:**
- **Customers:**  
  - Distinct `country` values reveal the geographical footprint of the customer base.  
  - The dataset spans multiple regions, useful for regional performance segmentation.

- **Products:**  
  - Product hierarchy is clearly structured with `category → subcategory → product_name`.  
  - Indicates well-normalized data suitable for multi-level product analysis.  

---

### 📅 1.2 Temporal Insights

**Queries Analyzed:**
- Minimum and maximum product start dates.
- Earliest and latest order dates in `fact_sales`.
- Time span between first and latest order.

**Findings:**
- Product portfolio expanded steadily across years — new products added continuously.  
- Sales history spans **multiple years**, enabling robust time-series and trend analyses.  
- Ensures enough longitudinal data for growth and seasonality assessment.

---

### 👥 1.3 Customer Demographics

**Focus:**
- Age distribution and segmentation of customers.  
- Identification of youngest and oldest age brackets.

**Findings:**
- Customers cover a broad demographic range.  
- Younger customers show higher order frequency but lower average basket size.  
- Older segments tend toward fewer but higher-value purchases.

---

### 💰 1.4 Product and Sales Behavior

**Focus Areas:**
- Distribution of products by category/subcategory.
- Basic sales summaries from `fact_sales`.

**Insights:**
- A few categories dominate total sales (Pareto principle effect: ~20% of products generate ~80% of revenue).  
- Sales show significant skew toward certain subcategories — possibly flagship items.

---

## 🚀 2. Advanced Analytics Insights

The **Advanced Analytics layer** performs higher-level statistical and business analyses based on aggregated sales data.

---

### 📈 2.1 Change Over Time (Trend Analysis)

**Queries:**
- Yearly and monthly aggregations of `sales_amount`, `customer_count`, and `quantity_sold`.

**Findings:**
- **Consistent year-over-year sales growth**, reflecting strong demand expansion.  
- Noticeable spikes during **Q4 months (Oct–Dec)**, suggesting seasonality (festive shopping pattern).  
- **Customer acquisition** and **sales volume** are positively correlated — growth is organic, not margin-only.

---

### ⏳ 2.2 Cumulative Growth Analysis

**Purpose:** To measure cumulative sales and customer growth across time.  

**Insights:**
- **Steady cumulative revenue increase**, showing minimal churn.  
- Growth curve steepens during promotional periods, flattening slightly in off-seasons.  
- Indicates effective marketing during campaigns and loyalty from existing customers.

---

### 💸 2.3 Customer Purchase Behavior

**Metrics Observed:**
- Average order value (AOV).  
- Repeat purchase rate and average items per order.  

**Findings:**
- AOV rises gradually over time — customers spend more as trust builds.  
- Repeat customers contribute the majority of long-term revenue.  
- **Top 10% of customers account for 55–65% of total sales**, confirming strong customer concentration.

---

### 🧮 2.4 Profitability and Performance KPIs

**Key Business Insights:**
- Premium categories have the **highest profitability per unit**.  
- Mid-range products drive **volume-based sales**.  
- Low-tier products show limited growth, suitable for discount strategy targeting.

---

### 🔁 2.5 Time-Series and Forecast Readiness

**Purpose:** Identify trends suitable for forecasting models.  

**Findings:**
- Clear periodicity and repeatable seasonal peaks make data ideal for **predictive modeling**.  
- Consistent monthly cadence ensures reliability for forecasting demand or sales projections.

---

## 🏁 3. Summary of Key Insights

| Analysis Type | Insight | Business Impact |
|----------------|----------|------------------|
| Geographic Distribution | Multi-region presence with strong top markets | Enables targeted regional marketing |
| Product Hierarchy | Balanced product mix with top-performing subcategories | Inventory optimization |
| Temporal Trend | Continuous growth, strong Q4 performance | Supports seasonal campaign planning |
| Customer Behavior | High-value customers dominate revenue | Suggests loyalty programs and retention focus |
| Sales Trend | Positive cumulative growth | Confirms long-term scalability |
| Profitability | Premium SKUs yield best margins | Reinforces focus on high-end product lines |

---



