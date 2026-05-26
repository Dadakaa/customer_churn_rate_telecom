```sql
SELECT
    churn,
    COUNT(*) AS customers
FROM telco_churn
GROUP BY churn;
```
