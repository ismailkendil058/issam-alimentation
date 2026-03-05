import { NavLink, Outlet } from "react-router-dom";
import { BarChart3, Users, Layers, Package, Warehouse } from "lucide-react";

const AdminLayout = () => {
  const links = [
    { to: "/admin", icon: BarChart3, label: "الإحصائيات", end: true },
    { to: "/admin/workers", icon: Users, label: "العمال" },
    { to: "/admin/products", icon: Package, label: "المنتجات" },
    { to: "/admin/inventory", icon: Warehouse, label: "المخزون" },
  ];

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <header className="px-4 py-3 border-b border-border flex items-center justify-between sticky top-0 bg-background z-30">
        <h1 className="font-semibold tracking-tight">Alimentation Issam</h1>
      </header>

      <div className="flex-1 overflow-y-auto pb-20">
        <Outlet />
      </div>

      <nav className="fixed bottom-0 left-0 right-0 bg-card border-t border-border z-40">
        <div className="flex justify-around py-2">
          {links.map((link) => (
            <NavLink
              key={link.to}
              to={link.to}
              end={link.end}
              className={({ isActive }) =>
                `flex flex-col items-center gap-0.5 px-2 py-1 text-xs transition-colors ${isActive ? "text-foreground" : "text-muted-foreground"
                }`
              }
            >
              <link.icon className="w-5 h-5" />
              {link.label}
            </NavLink>
          ))}
        </div>
      </nav>
    </div>
  );
};

export default AdminLayout;
