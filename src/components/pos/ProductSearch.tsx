import { Input } from "@/components/ui/input";
import { Search } from "lucide-react";

interface ProductSearchProps {
  search: string;
  onSearchChange: (value: string) => void;
}

const ProductSearch = ({ search, onSearchChange }: ProductSearchProps) => {
  return (
    <div className="px-4 py-3">
      <div className="flex gap-2">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            placeholder="البحث عن المنتجات أو الرمز الشريطي..."
            value={search}
            onChange={(e) => onSearchChange(e.target.value)}
            className="pl-9 h-11 rounded-xl bg-secondary border-0"
          />
        </div>
      </div>
    </div>
  );
};

export default ProductSearch;
