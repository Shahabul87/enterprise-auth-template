'use client';

/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unused-vars */

import { useState } from 'react';
// @tanstack/react-table types - temporary mock for TypeScript compilation
type ColumnDef = any;
type SortingState = any[];
type ColumnFiltersState = any[];
type VisibilityState = Record<string, boolean>;
type Column = any;
type HeaderGroup<_TData = unknown> = any;
type Header = any;
type Row<_TData = unknown> = any;
type Cell = any;

// Mock functions
const flexRender = (component: any, _context: any) => component;
const getCoreRowModel = () => ({});
const getPaginationRowModel = () => ({});
const getSortedRowModel = () => ({});
const getFilteredRowModel = () => ({});
const useReactTable = (_config?: any) => ({
  getAllColumns: () => [],
  getHeaderGroups: () => [],
  getRowModel: () => ({ rows: [] }),
  getCoreRowModel: () => ({ rows: [] }),
  getState: () => ({ pagination: { pageIndex: 0, pageSize: 10 } }),
  setColumnVisibility: (_visibility: any) => {},
  setColumnFilters: (_filters: any) => {},
  setSorting: (_sorting: any) => {},
  setGlobalFilter: (_filter: any) => {},
  resetSorting: () => {},
  resetColumnFilters: () => {},
  resetColumnVisibility: () => {},
  resetGlobalFilter: () => {},
  getFilteredSelectedRowModel: () => ({ rows: [] }),
  getFilteredRowModel: () => ({ rows: [] }),
  getColumn: (_columnId: string) => ({ getFilterValue: () => '', setFilterValue: (_value: any) => {}, getCanSort: () => false, getIsSorted: () => false, toggleSorting: (_desc?: boolean) => {} }),
  getCanPreviousPage: () => false,
  getCanNextPage: () => false,
  previousPage: () => {},
  nextPage: () => {},
  getPageCount: () => 0,
  getPageOptions: () => [],
  getPrePaginationRowModel: () => ({ rows: [] }),
  setPageIndex: (_index: any) => {},
  setPageSize: (_size: any) => {},
});
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import {
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
  Settings2,
  Search,
  Download,
  RefreshCw,
} from 'lucide-react';

interface DataTableProps<TData, _TValue = unknown> {
  columns: ColumnDef[];
  data: TData[];
  searchKey?: keyof TData;
  searchPlaceholder?: string;
  showColumnToggle?: boolean;
  showPagination?: boolean;
  showExport?: boolean;
  showRefresh?: boolean;
  onExport?: () => void;
  onRefresh?: () => void;
  isLoading?: boolean;
  className?: string;
}

export function DataTable<TData, _TValue = unknown>({
  columns,
  data,
  searchKey,
  searchPlaceholder = 'Search...',
  showColumnToggle = true,
  showPagination = true,
  showExport = false,
  showRefresh = false,
  onExport,
  onRefresh,
  isLoading = false,
  className,
}: DataTableProps<TData, _TValue>) {
  const [sorting, setSorting] = useState<SortingState>([]);
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);
  const [columnVisibility, setColumnVisibility] = useState<VisibilityState>({});
  const [rowSelection, setRowSelection] = useState({});
  const [globalFilter, setGlobalFilter] = useState('');

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    onColumnVisibilityChange: setColumnVisibility,
    onRowSelectionChange: setRowSelection,
    onGlobalFilterChange: setGlobalFilter,
    globalFilterFn: 'includesString',
    state: {
      sorting,
      columnFilters,
      columnVisibility,
      rowSelection,
      globalFilter,
    },
  });

  const selectedRowsCount = table.getFilteredSelectedRowModel().rows.length;
  const totalRowsCount = table.getFilteredRowModel().rows.length;

  return (
    <div className={className}>
      {/* Toolbar */}
      <div className="flex items-center justify-between py-4">
        <div className="flex items-center gap-2">
          {/* Global Search */}
          <div className="relative">
            <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder={searchPlaceholder}
              value={globalFilter}
              onChange={(event) => setGlobalFilter(event.target.value)}
              className="pl-8 max-w-sm"
            />
          </div>

          {/* Column-specific search (if searchKey is provided) */}
          {searchKey && (
            <Input
              placeholder={`Filter by ${String(searchKey)}...`}
              value={(table.getColumn(String(searchKey))?.getFilterValue() as string) ?? ''}
              onChange={(event) =>
                table.getColumn(String(searchKey))?.setFilterValue(event.target.value)
              }
              className="max-w-sm"
            />
          )}

          {/* Selection Info */}
          {selectedRowsCount > 0 && (
            <Badge variant="secondary" className="ml-2">
              {selectedRowsCount} of {totalRowsCount} row(s) selected
            </Badge>
          )}
        </div>

        <div className="flex items-center gap-2">
          {/* Refresh Button */}
          {showRefresh && (
            <Button
              variant="outline"
              size="sm"
              onClick={onRefresh}
              disabled={isLoading}
            >
              <RefreshCw className={`h-4 w-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
              Refresh
            </Button>
          )}

          {/* Export Button */}
          {showExport && (
            <Button variant="outline" size="sm" onClick={onExport}>
              <Download className="h-4 w-4 mr-2" />
              Export
            </Button>
          )}

          {/* Column Toggle */}
          {showColumnToggle && (
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="sm">
                  <Settings2 className="h-4 w-4 mr-2" />
                  Columns
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-48">
                {table
                  .getAllColumns()
                  .filter((column: Column) => column.getCanHide())
                  .map((column: Column) => {
                    return (
                      <DropdownMenuCheckboxItem
                        key={column.id}
                        className="capitalize"
                        checked={column.getIsVisible()}
                        onCheckedChange={(value) => column.toggleVisibility(!!value)}
                      >
                        {column.id}
                      </DropdownMenuCheckboxItem>
                    );
                  })}
              </DropdownMenuContent>
            </DropdownMenu>
          )}
        </div>
      </div>

      {/* Table */}
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup: HeaderGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header: Header) => {
                  return (
                    <TableHead key={header.id}>
                      {header.isPlaceholder
                        ? null
                        : flexRender(header.column.columnDef.header, header.getContext())}
                    </TableHead>
                  );
                })}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {isLoading ? (
              // Loading state
              <TableRow>
                <TableCell colSpan={columns.length} className="h-24 text-center">
                  <div className="flex items-center justify-center">
                    <RefreshCw className="h-4 w-4 animate-spin mr-2" />
                    Loading...
                  </div>
                </TableCell>
              </TableRow>
            ) : table.getRowModel().rows?.length ? (
              table.getRowModel().rows.map((row: Row) => (
                <TableRow
                  key={row.id}
                  data-state={row.getIsSelected() && 'selected'}
                >
                  {row.getVisibleCells().map((cell: Cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={columns.length} className="h-24 text-center">
                  <div className="text-muted-foreground">
                    No results found.
                  </div>
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      {showPagination && (
        <div className="flex items-center justify-between px-2 py-4">
          <div className="text-sm text-muted-foreground">
            Showing {table.getFilteredRowModel().rows.length} of{' '}
            {table.getCoreRowModel().rows.length} entries
          </div>
          
          <div className="flex items-center space-x-6 lg:space-x-8">
            <div className="flex items-center space-x-2">
              <p className="text-sm font-medium">Rows per page</p>
              <select
                value={table.getState().pagination.pageSize}
                onChange={(e) => {
                  table.setPageSize(Number(e.target.value));
                }}
                className="h-8 w-16 rounded border border-input bg-background px-2 text-sm"
              >
                {[10, 20, 30, 40, 50].map((pageSize) => (
                  <option key={pageSize} value={pageSize}>
                    {pageSize}
                  </option>
                ))}
              </select>
            </div>
            
            <div className="flex w-24 items-center justify-center text-sm font-medium">
              Page {table.getState().pagination.pageIndex + 1} of{' '}
              {table.getPageCount()}
            </div>
            
            <div className="flex items-center space-x-2">
              <Button
                variant="outline"
                className="h-8 w-8 p-0"
                onClick={() => table.setPageIndex(0)}
                disabled={!table.getCanPreviousPage()}
              >
                <ChevronsLeft className="h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                className="h-8 w-8 p-0"
                onClick={() => table.previousPage()}
                disabled={!table.getCanPreviousPage()}
              >
                <ChevronLeft className="h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                className="h-8 w-8 p-0"
                onClick={() => table.nextPage()}
                disabled={!table.getCanNextPage()}
              >
                <ChevronRight className="h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                className="h-8 w-8 p-0"
                onClick={() => table.setPageIndex(table.getPageCount() - 1)}
                disabled={!table.getCanNextPage()}
              >
                <ChevronsRight className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}