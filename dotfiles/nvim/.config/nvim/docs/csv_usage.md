# CSV Table Viewer Usage Guide

## Overview
Using the reliable `csv.vim` plugin for CSV file handling. This classic plugin provides robust CSV table formatting and manipulation features.

## Features
- **Auto-arrange columns**: Automatically formats CSV as a table on file open
- **Column manipulation**: Add, delete, move columns easily
- **Statistical functions**: Sum, average, min/max calculations
- **Flexible delimiters**: Supports comma, semicolon, pipe delimiters
- **Visual alignment**: Clean table formatting with proper spacing

## Automatic Activation
The plugin automatically activates and arranges columns when you open `.csv` files.

## Commands

### Table Formatting
- `:ArrangeColumn` - Format CSV as a table
- `:UnArrangeColumn` - Remove table formatting
- `:CSVTabularize` - Alternative tabularize command

### Column Operations
- `:DeleteColumn` - Delete current column
- `:AddColumn` - Add new column
- `:MoveColumn` - Move current column

### Statistical Functions
- `:SumCol` - Sum values in current column
- `:AvgCol` - Average values in current column
- `:MaxCol` - Find maximum value in column
- `:MinCol` - Find minimum value in column

## Key Mappings

### CSV Commands (work only in CSV files)
- `,ca` - Arrange CSV columns
- `,cu` - Un-arrange CSV columns  
- `,ct` - Tabularize CSV
- `,ch` - Highlight current column

### Column Navigation (in CSV files)
- `H` - Move to previous column (left)
- `L` - Move to next column (right)
- `K` - Move up in same column
- `J` - Move down in same column
- `W` - Show current column number

## Usage Examples

### 1. Viewing Database Query Results
```bash
# Export query results to CSV
psql -c "SELECT * FROM users" -o users.csv
# Open in Neovim - auto-arranges as table
nvim users.csv
```

### 2. Manual Table Formatting
```vim
" If auto-arrange didn't work
:ArrangeColumn

" Remove formatting to edit raw CSV
:UnArrangeColumn

" Re-format after editing
:ArrangeColumn
```

### 3. Column Analysis
```vim
" Move cursor to a numeric column
:SumCol     " Get sum of column values
:AvgCol     " Get average
:MaxCol     " Get maximum value
:MinCol     " Get minimum value
```

### 4. Column Manipulation
```vim
" Add new column after current
:AddColumn

" Delete current column
:DeleteColumn

" Move column to different position
:MoveColumn
```

## Configuration

The plugin is pre-configured with optimal settings:
- **Auto-arrange**: Enabled for all CSV files
- **Alignment**: Left-aligned columns
- **Delimiters**: Auto-detect comma, semicolon, pipe
- **Buffer options**: No wrap, line numbers, cursor line

## Integration with Your Workflow

### Database Work (with DBEE)
1. Execute SQL query in DBEE
2. Export results to CSV
3. Open CSV file - automatic table formatting
4. Use statistical functions for quick analysis

### Data Analysis
- Quick column statistics without leaving Neovim
- Visual table format for better data comprehension
- Edit CSV data with proper column alignment

## Tips

1. **Large Files**: Works well with large CSV files
2. **Mixed Data**: Handles text and numeric columns properly
3. **Quick Stats**: Use `:SumCol`, `:AvgCol` for quick calculations
4. **Column Navigation**: Use normal vim motions to move between fields

## Troubleshooting

### Table Not Formatting
1. Check file has `.csv` extension
2. Manually run `:ArrangeColumn`
3. Verify delimiter is supported (comma, semicolon, pipe)

### Performance with Large Files
- Plugin handles large files well
- If slow, consider splitting very large files
- Use `:UnArrangeColumn` for faster editing, then `:ArrangeColumn` to view

### Column Operations Not Working
- Ensure cursor is in the target column
- Check that data is properly arranged first
- Some operations require numeric data

This classic plugin provides reliable CSV handling that integrates perfectly with your database and data analysis workflow.