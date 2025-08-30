// path: src/admin/widgets/login-customization.tsx
import { defineWidgetConfig } from "@medusajs/admin-sdk";
import { useEffect } from "react";
import Logo from "../assets/G&G-final-logo.png";

const LoginCustomizationsWidget = () => {
  useEffect(() => {
    const logoWrapper = document.querySelector(
    'div.h-\\[50px\\].w-\\[50px\\].rounded-xl'
  )
  if (logoWrapper) {
    (logoWrapper as HTMLElement).style.display = "none";
  }
    // Hide Medusa default heading (h1)
    const heading = document.querySelector("h1");
    if (heading) {
      heading.style.display = "none";
    }

   const paragraph = document.querySelector("p");
    if (paragraph) {
      paragraph.style.display = "none";
    }
  }, []);

  return (
    <>
      <style>
       {`
        .m-4.flex.w-full.max-w-\\[280px\\].flex-col.items-center {
          max-width: 400px !important;
        }
      `}
      </style>

      <div className="mb-6 flex flex-col items-center">
        {/* Custom Logo */}
        <img
          src={Logo}
          alt="Grox & Gloryx Logo"
          className="w-48 mb-4"
        />

        {/* Custom Headings */}
        <h1 className="font-sans font-bold text-2xl text-center">
          Welcome to Grox & Gloryx Admin
        </h1>
        <p className="mt-2 font-normal text-gray-600 text-center">
          Sign in to access the account area
        </p>
      </div>
    </>
  );
};

export const config = defineWidgetConfig({
  zone: "login.before",
});

export default LoginCustomizationsWidget;
