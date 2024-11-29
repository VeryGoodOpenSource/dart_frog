"use strict";(self.webpackChunkdart_frog_docs=self.webpackChunkdart_frog_docs||[]).push([[549],{4196:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>c,contentTitle:()=>a,default:()=>p,frontMatter:()=>s,metadata:()=>n,toc:()=>d});const n=JSON.parse('{"id":"advanced/custom_entrypoint","title":"\ud83c\udfac Custom Server Entrypoint","description":"Dart Frog supports creating a custom entrypoint in cases where you need fine-grained control over the server initialization or wish to execute code prior to starting the server.","source":"@site/docs/advanced/custom_entrypoint.md","sourceDirName":"advanced","slug":"/advanced/custom_entrypoint","permalink":"/docs/advanced/custom_entrypoint","draft":false,"unlisted":false,"editUrl":"https://github.com/VeryGoodOpenSource/dart_frog/tree/main/docs/docs/advanced/custom_entrypoint.md","tags":[],"version":"current","sidebarPosition":1,"frontMatter":{"sidebar_position":1,"title":"\ud83c\udfac Custom Server Entrypoint"},"sidebar":"docs","previous":{"title":"Advanced","permalink":"/docs/category/advanced"},"next":{"title":"\ud83d\udeeb Custom Init Method","permalink":"/docs/advanced/custom_init_method"}}');var o=r(4848),i=r(8453);const s={sidebar_position:1,title:"\ud83c\udfac Custom Server Entrypoint"},a="Custom Server Entrypoint \ud83c\udfac",c={},d=[{value:"Creating a Custom Entrypoint \u2728",id:"creating-a-custom-entrypoint-",level:2}];function u(e){const t={code:"code",h1:"h1",h2:"h2",header:"header",p:"p",pre:"pre",...(0,i.R)(),...e.components};return(0,o.jsxs)(o.Fragment,{children:[(0,o.jsx)(t.header,{children:(0,o.jsx)(t.h1,{id:"custom-server-entrypoint-",children:"Custom Server Entrypoint \ud83c\udfac"})}),"\n",(0,o.jsx)(t.p,{children:"Dart Frog supports creating a custom entrypoint in cases where you need fine-grained control over the server initialization or wish to execute code prior to starting the server."}),"\n",(0,o.jsx)(t.h2,{id:"creating-a-custom-entrypoint-",children:"Creating a Custom Entrypoint \u2728"}),"\n",(0,o.jsxs)(t.p,{children:["To create a custom entrypoint, simply create a ",(0,o.jsx)(t.code,{children:"main.dart"})," file at the root of your Dart Frog project. The ",(0,o.jsx)(t.code,{children:"main.dart"})," file must expose a top-level ",(0,o.jsx)(t.code,{children:"run"})," method with the following signature:"]}),"\n",(0,o.jsx)(t.pre,{children:(0,o.jsx)(t.code,{className:"language-dart",children:"import 'dart:io';\n\nimport 'package:dart_frog/dart_frog.dart';\n\nFuture<HttpServer> run(Handler handler, InternetAddress ip, int port) {\n  // 1. Execute any custom code prior to starting the server...\n\n  // 2. Use the provided `handler`, `ip`, and `port` to create a custom `HttpServer`.\n  // Or use the Dart Frog serve method to do that for you.\n  return serve(handler, ip, port);\n}\n"})}),"\n",(0,o.jsxs)(t.p,{children:["The Dart Frog CLI will detect the custom entrypoint and execute your custom ",(0,o.jsx)(t.code,{children:"run"})," method instead of the default implementation."]})]})}function p(e={}){const{wrapper:t}={...(0,i.R)(),...e.components};return t?(0,o.jsx)(t,{...e,children:(0,o.jsx)(u,{...e})}):u(e)}},8453:(e,t,r)=>{r.d(t,{R:()=>s,x:()=>a});var n=r(6540);const o={},i=n.createContext(o);function s(e){const t=n.useContext(i);return n.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function a(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(o):e.components||o:s(e.components),n.createElement(i.Provider,{value:t},e.children)}}}]);