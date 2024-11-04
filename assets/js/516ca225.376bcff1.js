"use strict";(self.webpackChunkdart_frog_docs=self.webpackChunkdart_frog_docs||[]).push([[146],{6985:(t,e,n)=>{n.r(e),n.d(e,{assets:()=>a,contentTitle:()=>d,default:()=>l,frontMatter:()=>s,metadata:()=>o,toc:()=>c});const o=JSON.parse('{"id":"advanced/custom_init_method","title":"\ud83d\udeeb Custom Init Method","description":"Dart Frog supports creating a custom entrypoint as shown in the Custom Entrypoint docs but that will run every time the server hot reloads. In cases where you want to initialize something only on server start, like setting up a database connection, you can use the init method.","source":"@site/docs/advanced/custom_init_method.md","sourceDirName":"advanced","slug":"/advanced/custom_init_method","permalink":"/docs/advanced/custom_init_method","draft":false,"unlisted":false,"editUrl":"https://github.com/VeryGoodOpenSource/dart_frog/tree/main/docs/docs/advanced/custom_init_method.md","tags":[],"version":"current","sidebarPosition":2,"frontMatter":{"sidebar_position":2,"title":"\ud83d\udeeb Custom Init Method"},"sidebar":"docs","previous":{"title":"\ud83c\udfac Custom Server Entrypoint","permalink":"/docs/advanced/custom_entrypoint"},"next":{"title":"\ud83d\udc33 Custom Dockerfile","permalink":"/docs/advanced/custom_dockerfile"}}');var i=n(4848),r=n(8453);const s={sidebar_position:2,title:"\ud83d\udeeb Custom Init Method"},d="Custom Init Method \ud83d\udeeb",a={},c=[{value:"Creating a Custom Init Method \u2728",id:"creating-a-custom-init-method-",level:2}];function h(t){const e={a:"a",admonition:"admonition",code:"code",h1:"h1",h2:"h2",header:"header",p:"p",pre:"pre",...(0,r.R)(),...t.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(e.header,{children:(0,i.jsx)(e.h1,{id:"custom-init-method-",children:"Custom Init Method \ud83d\udeeb"})}),"\n",(0,i.jsxs)(e.p,{children:["Dart Frog supports creating a custom entrypoint as shown in the ",(0,i.jsx)(e.a,{href:"/docs/advanced/custom_entrypoint",children:"Custom Entrypoint docs"})," but that will run every time the server hot reloads. In cases where you want to initialize something only on server start, like setting up a database connection, you can use the ",(0,i.jsx)(e.code,{children:"init"})," method."]}),"\n",(0,i.jsx)(e.h2,{id:"creating-a-custom-init-method-",children:"Creating a Custom Init Method \u2728"}),"\n",(0,i.jsxs)(e.p,{children:["To create a custom init method, simply create a ",(0,i.jsx)(e.code,{children:"main.dart"})," file at the root of your Dart Frog project."]}),"\n",(0,i.jsx)(e.admonition,{type:"warning",children:(0,i.jsxs)(e.p,{children:["Keep in mind that the ",(0,i.jsx)(e.code,{children:"main.dart"})," file must expose a top-level ",(0,i.jsx)(e.code,{children:"run"})," as mentioned in the ",(0,i.jsx)(e.a,{href:"/docs/advanced/custom_entrypoint",children:"Custom Entrypoint docs"}),"."]})}),"\n",(0,i.jsxs)(e.p,{children:["Add the following top-level ",(0,i.jsx)(e.code,{children:"init"})," method to the ",(0,i.jsx)(e.code,{children:"main.dart"})," file:"]}),"\n",(0,i.jsx)(e.pre,{children:(0,i.jsx)(e.code,{className:"language-dart",children:"import 'dart:io';\n\nimport 'package:dart_frog/dart_frog.dart';\n\nFuture<void> init(InternetAddress ip, int port) async {\n  // Any code initialized within this method will only run on server start, any hot reloads\n  // afterwards will not trigger this method until a hot restart.\n}\n\nFuture<HttpServer> run(Handler handler, InternetAddress ip, int port) {\n    ...\n}\n"})}),"\n",(0,i.jsxs)(e.p,{children:["The Dart Frog CLI will detect the ",(0,i.jsx)(e.code,{children:"init"})," method and execute it on server start."]})]})}function l(t={}){const{wrapper:e}={...(0,r.R)(),...t.components};return e?(0,i.jsx)(e,{...t,children:(0,i.jsx)(h,{...t})}):h(t)}},8453:(t,e,n)=>{n.d(e,{R:()=>s,x:()=>d});var o=n(6540);const i={},r=o.createContext(i);function s(t){const e=o.useContext(r);return o.useMemo((function(){return"function"==typeof t?t(e):{...e,...t}}),[e,t])}function d(t){let e;return e=t.disableParentContext?"function"==typeof t.components?t.components(i):t.components||i:s(t.components),o.createElement(r.Provider,{value:e},t.children)}}}]);