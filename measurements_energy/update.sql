ALTER TABLE session_details ADD COLUMN model_size REAL;
ALTER TABLE session_details ADD COLUMN model_quantization_level  INTEGER;

-- 2) Populate them in one pass
UPDATE session_details
SET
  -- extract everything between the ':' and the first 'b' as a REAL
  model_size = CAST(
    SUBSTR(
      model,
      INSTR(model, ':') + 1,
      INSTR(model, 'b') - INSTR(model, ':') - 1
    ) 
    AS REAL
  ),

  -- map the suffix to quantization bits
  model_quantization_level = CASE
    WHEN model LIKE '%-fp16'   THEN 16
    WHEN model LIKE '%-q4_%'   THEN 4
    WHEN model LIKE '%-q8_%'   THEN 8
    ELSE NULL
  END;

ALTER TABLE session_results ADD COLUMN model_size REAL;
ALTER TABLE session_results ADD COLUMN model_quantization_level  INTEGER;

-- 2) Populate them in one pass
UPDATE session_results
SET
  -- extract everything between the ':' and the first 'b' as a REAL
  model_size = CAST(
    SUBSTR(
      model,
      INSTR(model, ':') + 1,
      INSTR(model, 'b') - INSTR(model, ':') - 1
    ) 
    AS REAL
  ),

  -- map the suffix to quantization bits
  model_quantization_level = CASE
    WHEN model LIKE '%-fp16'   THEN 16
    WHEN model LIKE '%-q4_%'   THEN 4
    WHEN model LIKE '%-q8_%'   THEN 8
    ELSE NULL
  END;