"use strict";(self.webpackChunkdart_frog_docs=self.webpackChunkdart_frog_docs||[]).push([[813],{2671:(e,t,i)=>{i.r(t),i.d(t,{assets:()=>a,contentTitle:()=>c,default:()=>h,frontMatter:()=>o,metadata:()=>n,toc:()=>l});const n=JSON.parse('{"id":"basics/serving-static-files","title":"\ud83d\udcc1 Serving Static Files","description":"Dart Frog supports serving static files including images, text, json, html, and more.","source":"@site/docs/basics/serving-static-files.md","sourceDirName":"basics","slug":"/basics/serving-static-files","permalink":"/docs/basics/serving-static-files","draft":false,"unlisted":false,"editUrl":"https://github.com/VeryGoodOpenSource/dart_frog/tree/main/docs/docs/basics/serving-static-files.md","tags":[],"version":"current","sidebarPosition":6,"frontMatter":{"sidebar_position":6,"title":"\ud83d\udcc1 Serving Static Files"},"sidebar":"docs","previous":{"title":"\ud83e\uddea Testing","permalink":"/docs/basics/testing"},"next":{"title":"\ud83c\udf31 Environments","permalink":"/docs/basics/environments"}}');var s=i(4848),r=i(8453);const o={sidebar_position:6,title:"\ud83d\udcc1 Serving Static Files"},c="Serving Static Files \ud83d\udcc1",a={},l=[{value:"Overview \ud83d\ude80",id:"overview-",level:2},{value:"Using a Custom Directory \u2728",id:"using-a-custom-directory-",level:2}];function d(e){const t={a:"a",admonition:"admonition",code:"code",h1:"h1",h2:"h2",header:"header",p:"p",pre:"pre",...(0,r.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(t.header,{children:(0,s.jsx)(t.h1,{id:"serving-static-files-",children:"Serving Static Files \ud83d\udcc1"})}),"\n",(0,s.jsx)(t.p,{children:"Dart Frog supports serving static files including images, text, json, html, and more."}),"\n",(0,s.jsx)(t.h2,{id:"overview-",children:"Overview \ud83d\ude80"}),"\n",(0,s.jsxs)(t.p,{children:["To serve static files, place the files within the ",(0,s.jsx)(t.code,{children:"public"})," directory at the root of the project."]}),"\n",(0,s.jsxs)(t.p,{children:["For example, if you create a file in ",(0,s.jsx)(t.code,{children:"public/hello.txt"})," which contains the following:"]}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{children:"Hello World!\n"})}),"\n",(0,s.jsxs)(t.p,{children:["The contents of the file will be available at ",(0,s.jsx)(t.a,{href:"http://localhost:8080/hello.txt",children:"http://localhost:8080/hello.txt"}),"."]}),"\n",(0,s.jsxs)(t.p,{children:["The ",(0,s.jsx)(t.code,{children:"public"})," directory can also contain static files within subdirectories. For example, if you create an image in ",(0,s.jsx)(t.code,{children:"public/images/unicorn.png"}),", the contents of the file will be available at ",(0,s.jsx)(t.a,{href:"http://localhost:8080/images/unicorn.png",children:"http://localhost:8080/images/unicorn.png"}),"."]}),"\n",(0,s.jsx)(t.p,{children:"When running a development server, static files can be added, removed, and modified without needing to restart the server thanks to hot reload \u26a1\ufe0f."}),"\n",(0,s.jsx)(t.admonition,{type:"note",children:(0,s.jsxs)(t.p,{children:["Static file support requires ",(0,s.jsx)(t.code,{children:"dart_frog ^0.0.2-dev.7"})," and ",(0,s.jsx)(t.code,{children:"dart_frog_cli ^0.0.1-dev.8"})]})}),"\n",(0,s.jsx)(t.admonition,{type:"note",children:(0,s.jsxs)(t.p,{children:["The ",(0,s.jsx)(t.code,{children:"/public"})," folder must be at the root of the project and cannot be renamed. This is the only directory used to serve static files."]})}),"\n",(0,s.jsx)(t.admonition,{type:"note",children:(0,s.jsxs)(t.p,{children:["In production, only files that are in the ",(0,s.jsx)(t.code,{children:"/public"})," directory at build time will be served."]})}),"\n",(0,s.jsx)(t.admonition,{type:"caution",children:(0,s.jsxs)(t.p,{children:["Be sure not to have a static file with the same name as a file in the ",(0,s.jsx)(t.code,{children:"/routes"})," directory as this will result in a conflict."]})}),"\n",(0,s.jsx)(t.h2,{id:"using-a-custom-directory-",children:"Using a Custom Directory \u2728"}),"\n",(0,s.jsxs)(t.p,{children:["Even though Dart Frog uses the ",(0,s.jsx)(t.code,{children:"public"})," directory for serving static files by default, you can also specify a custom directory by creating a ",(0,s.jsx)(t.a,{href:"/docs/advanced/custom_entrypoint",children:"custom entrypoint"}),"."]}),"\n",(0,s.jsxs)(t.p,{children:["Create a ",(0,s.jsx)(t.code,{children:"main.dart"})," at the root of your project with the following contents:"]}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-dart",children:"import 'dart:io';\n\nimport 'package:dart_frog/dart_frog.dart';\n\nFuture<HttpServer> run(Handler handler, InternetAddress ip, int port) {\n  const customStaticFilePath = 'api/static';\n  final cascade = Cascade()\n      .add(createStaticFileHandler(path: customStaticFilePath))\n      .add(handler);\n  return serve(cascade.handler, ip, port);\n}\n"})}),"\n",(0,s.jsxs)(t.p,{children:["In the above example, we're using ",(0,s.jsx)(t.code,{children:"api/static"})," as our static file directory but you can specify a path to any directory for Dart Frog to use."]})]})}function h(e={}){const{wrapper:t}={...(0,r.R)(),...e.components};return t?(0,s.jsx)(t,{...e,children:(0,s.jsx)(d,{...e})}):d(e)}},8453:(e,t,i)=>{i.d(t,{R:()=>o,x:()=>c});var n=i(6540);const s={},r=n.createContext(s);function o(e){const t=n.useContext(r);return n.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function c(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(s):e.components||s:o(e.components),n.createElement(r.Provider,{value:t},e.children)}}}]);