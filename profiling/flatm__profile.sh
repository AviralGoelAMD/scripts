#!/bin/bash
 
BIN=./bin/tile_example_gemm_weight_preshuffle
PREC=fp8
VERBOSITY=2
 
# List of all (m, n, k) triplets
ARGS_LIST=(
  "1 2048 5120"
  "1 5120 1024"
  "2 2048 5120"
  "2 5120 1024"
  "3 2048 5120"
  "3 5120 1024"
  "4 2048 5120"
  "4 5120 1024"
  "5 2048 5120"
  "5 5120 1024"
  "6 2048 5120"
  "6 5120 1024"
  "7 2048 5120"
  "7 5120 1024"
  "8 2048 5120"
  "8 5120 1024"
  "9 2048 5120"
  "9 5120 1024"
  "10 2048 5120"
  "10 5120 1024"
  "11 2048 5120"
  "11 5120 1024"
  "12 2048 5120"
  "12 5120 1024"
  "13 2048 5120"
  "13 5120 1024"
  "14 2048 5120"
  "14 5120 1024"
  "15 2048 5120"
  "15 5120 1024"
  "16 2048 5120"
  "16 5120 1024"
  "2048 5120 1024"
  "2048 5120 8192"
  "2048 7168 8192"
  "2048 8192 3584"
  "16384 7168 8192"
  "16384 8192 3584"
)
 
# Output file
OUTPUT_FILE="mmflat_profile_results_v2.csv"
 
# Output header
echo "m,n,k,Pipeline,Time_ms,TFlops,GBps" > "$OUTPUT_FILE"
 
# Loop over each argument set
for args in "${ARGS_LIST[@]}"; do
  read -r m n k <<< "$args"
 
  echo "Running with m=$m, n=$n, k=$k..."
 
  # Use correct parameter order: -m=n -n=k -k=8192 (based on the working example)
  OUTPUT=$($BIN -m=$m -n=$n -k=$k -prec=$PREC -v=$VERBOSITY 2>/dev/null)
 
  # Extract pipeline name from the Launching kernel line
  PIPELINE=$(echo "$OUTPUT" | grep "Launching kernel with args:" | sed -n 's/.*Launching kernel with args: \([^,]*\).*/\1/p')

  # Extract performance metrics from the Run Gemm kernel line
  PERF_LINE=$(echo "$OUTPUT" | grep "Run Gemm kernel")
  if [ -n "$PERF_LINE" ]; then
    TIME_MS=$(echo "$PERF_LINE" | sed -n 's/.*: \([0-9.]*\) ms.*/\1/p')
    TFLOPS=$(echo "$PERF_LINE" | sed -n 's/.*, \([0-9.]*\) TFlops.*/\1/p')
    GBPS=$(echo "$PERF_LINE" | sed -n 's/.*, \([0-9.]*\) GB\/s.*/\1/p')
    
    # Extract verification result
    VERIFICATION=$(echo "$OUTPUT" | grep "The GPU verification result is:" | sed -n 's/.*The GPU verification result is: \([^,]*\).*/\1/p')
   
    echo "$m,$n,$k,$PIPELINE,$TIME_MS,$TFLOPS,$GBPS,$VERIFICATION" >> "$OUTPUT_FILE"
    echo "  Pipeline: $PIPELINE, Time: ${TIME_MS}ms, TFlops: $TFLOPS, GBps: $GBPS, Verification: $VERIFICATION"
  else
    echo "  No performance data found for m=$m, n=$n, k=$k"
    echo "$m,$n,$k,$PIPELINE,,,," >> "$OUTPUT_FILE"
  fi
done
 
echo "Results saved to $OUTPUT_FILE"