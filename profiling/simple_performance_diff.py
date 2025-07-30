#!/usr/bin/env python3
"""
Simple Performance Difference Script

This script compares performance metrics between two GEMM profiling runs:
- gemm_profile_results_fp16_no_barrier.csv
- gemm_profile_results_fp16.csv

It prints percentage changes for TFlops, GBps, and Time for each test case.
"""

import pandas as pd
from pathlib import Path

def load_data(file_path):
    """Load CSV data."""
    df = pd.read_csv(file_path)
    # Create a unique identifier for each test case
    df['test_case'] = df['m'].astype(str) + '_' + df['n'].astype(str) + '_' + df['k'].astype(str)
    return df

def calculate_changes(df_no_barrier, df_with_barrier):
    """Calculate percentage changes between the two runs."""
    
    # Merge the dataframes on test_case
    merged = pd.merge(df_no_barrier, df_with_barrier, 
                     on='test_case', 
                     suffixes=('_no_barrier', '_with_barrier'))
    
    # Calculate percentage changes
    merged['tflops_change_pct'] = ((merged['TFlops_no_barrier'] - merged['TFlops_with_barrier']) / 
                                  merged['TFlops_with_barrier'] * 100)
    merged['gbps_change_pct'] = ((merged['GBps_no_barrier'] - merged['GBps_with_barrier']) / 
                                merged['GBps_with_barrier'] * 100)
    merged['time_change_pct'] = ((merged['Time_ms_with_barrier'] - merged['Time_ms_no_barrier']) / 
                                merged['Time_ms_with_barrier'] * 100)
    
    return merged

def print_changes(merged_df):
    """Print percentage changes for each test case."""
    print("=" * 100)
    print("PERFORMANCE CHANGES: No Barrier vs With Barrier")
    print("=" * 100)
    print(f"{'Test Case':<20} {'TFlops Change':<15} {'GBps Change':<15} {'Time Change':<15}")
    print("-" * 100)
    
    # Sort by TFlops change
    sorted_df = merged_df.sort_values('tflops_change_pct', ascending=False)
    
    for idx, row in sorted_df.iterrows():
        test_case = f"m={row['m_no_barrier']}, n={row['n_no_barrier']}, k={row['k_no_barrier']}"
        tflops_change = f"{row['tflops_change_pct']:+.2f}%"
        gbps_change = f"{row['gbps_change_pct']:+.2f}%"
        time_change = f"{row['time_change_pct']:+.2f}%"
        
        print(f"{test_case:<20} {tflops_change:<15} {gbps_change:<15} {time_change:<15}")
    
    print("-" * 100)
    
    # Print summary
    print(f"\nSummary:")
    print(f"  Average TFlops change: {sorted_df['tflops_change_pct'].mean():+.2f}%")
    print(f"  Average GBps change: {sorted_df['gbps_change_pct'].mean():+.2f}%")
    print(f"  Average Time change: {sorted_df['time_change_pct'].mean():+.2f}%")
    print(f"  Total test cases: {len(sorted_df)}")

def main():
    """Main function."""
    # File paths
    no_barrier_file = "build/gemm_profile_results_fp16_no_barrier.csv"
    with_barrier_file = "build/gemm_profile_results_fp16.csv"
    
    # Check if files exist
    if not Path(no_barrier_file).exists():
        print(f"Error: {no_barrier_file} not found!")
        return
    if not Path(with_barrier_file).exists():
        print(f"Error: {with_barrier_file} not found!")
        return
    
    # Load data
    df_no_barrier = load_data(no_barrier_file)
    df_with_barrier = load_data(with_barrier_file)
    
    # Calculate changes
    merged_df = calculate_changes(df_no_barrier, df_with_barrier)
    
    # Print results
    print_changes(merged_df)

if __name__ == "__main__":
    main() 