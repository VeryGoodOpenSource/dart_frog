"use strict";(self.webpackChunkdart_frog_docs=self.webpackChunkdart_frog_docs||[]).push([[426],{9679:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>a,contentTitle:()=>o,default:()=>u,frontMatter:()=>h,metadata:()=>r,toc:()=>x});const r=JSON.parse('{"id":"advanced/daemon","title":"\ud83e\uddf0 Daemon","description":"Dart Frog daemon is a standing process that, during its lifetime, will be used by first and","source":"@site/docs/advanced/daemon.md","sourceDirName":"advanced","slug":"/advanced/daemon","permalink":"/docs/advanced/daemon","draft":false,"unlisted":false,"editUrl":"https://github.com/VeryGoodOpenSource/dart_frog/tree/main/docs/docs/advanced/daemon.md","tags":[],"version":"current","frontMatter":{},"sidebar":"docs","previous":{"title":"\ud83d\udc1b Debugging","permalink":"/docs/advanced/debugging"},"next":{"title":"Roadmap","permalink":"/docs/roadmap"}}');var s=t(4848),i=t(8453),d=(t(6540),t(1021));const c={tableOfContentsInline:"tableOfContentsInline_prmo"};function l(e){let{toc:n,minHeadingLevel:t,maxHeadingLevel:r}=e;return(0,s.jsx)("div",{className:c.tableOfContentsInline,children:(0,s.jsx)(d.A,{toc:n,minHeadingLevel:t,maxHeadingLevel:r,className:"table-of-contents",linkClassName:null})})}const h={},o="\ud83e\uddf0 Daemon",a={},x=[{value:"Usage example",id:"usage-example",level:4},{value:"<code>daemon</code> domain",id:"daemon-domain",level:2},{value:"Method: <code>requestVersion</code>",id:"method-requestversion",level:3},{value:"Method: <code>kill</code>",id:"method-kill",level:3},{value:"Event: <code>ready</code>",id:"event-ready",level:3},{value:"<code>dev_server</code> domain",id:"dev_server-domain",level:2},{value:"Method: <code>start</code>",id:"method-start",level:3},{value:"Method: <code>reload</code>",id:"method-reload",level:3},{value:"Method: <code>stop</code>",id:"method-stop",level:3},{value:"Event: <code>applicationStarting</code>",id:"event-applicationstarting",level:3},{value:"Event: <code>applicationExit</code>",id:"event-applicationexit",level:3},{value:"Dev server logging events",id:"dev-server-logging-events",level:3},{value:"<code>route_configuration</code> domain",id:"route_configuration-domain",level:2},{value:"Method: <code>watcherStart</code>",id:"method-watcherstart",level:3},{value:"Method: <code>watcherStop</code>",id:"method-watcherstop",level:3},{value:"Method: <code>watcherGenerateRouteConfiguration</code>",id:"method-watchergeneraterouteconfiguration",level:3},{value:"Event: <code>changed</code>",id:"event-changed",level:3},{value:"Event: <code>watcherStart</code>",id:"event-watcherstart",level:3},{value:"Event: <code>watcherExit</code>",id:"event-watcherexit",level:3},{value:"Route configuration watcher logging events",id:"route-configuration-watcher-logging-events",level:3}];function j(e){const n={a:"a",admonition:"admonition",code:"code",h1:"h1",h2:"h2",h3:"h3",h4:"h4",header:"header",hr:"hr",li:"li",p:"p",pre:"pre",strong:"strong",table:"table",tbody:"tbody",td:"td",th:"th",thead:"thead",tr:"tr",ul:"ul",...(0,i.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(n.header,{children:(0,s.jsx)(n.h1,{id:"-daemon",children:"\ud83e\uddf0 Daemon"})}),"\n",(0,s.jsx)(n.p,{children:"Dart Frog daemon is a standing process that, during its lifetime, will be used by first and\nthird-party tools to manage, build, and diagnose Dart Frog projects."}),"\n",(0,s.jsx)(n.p,{children:"By design, the daemon is able to manage multiple projects simultaneously; it can also run multiple\napplication instances of the same project if necessary."}),"\n",(0,s.jsxs)(n.p,{children:["To start using it, install the Dart Frog CLI and run the ",(0,s.jsx)(n.code,{children:"dart_frog daemon"})," command. Once running, communicating with it can be done via ",(0,s.jsx)(n.a,{href:"https://www.jsonrpc.org/",children:"JSON-RPC"})," over stdin/stdout to receive and send messages."]}),"\n",(0,s.jsx)(n.admonition,{type:"note",children:(0,s.jsxs)(n.p,{children:["For a concrete sample of how to interact with the daemon via ",(0,s.jsx)(n.code,{children:"stdio"}),", see the ",(0,s.jsx)(n.a,{href:"https://github.com/VeryGoodOpenSource/dart_frog/tree/main/packages/dart_frog_cli/e2e/test/daemon",children:"end-to-end tests"}),"."]})}),"\n",(0,s.jsx)(n.p,{children:"There are three types of messages:"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Request"}),": A request is a message sent by a client to the daemon. The daemon will process the\nrequest and send a response back to the client. A request is essentially a method invocation."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Response"}),": A response is a message sent by the daemon to a client in response to a request."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Event"}),": An event is a message sent by the daemon to a client. The daemon will send an event to\na client when something happens, for example, when a running dev server stops."]}),"\n"]}),"\n",(0,s.jsx)(n.p,{children:"Every request should be met with a response as soon as possible so the caller can work with\ntimeouts. The daemon will send events to the client as they happen."}),"\n",(0,s.jsx)(n.admonition,{type:"warning",children:(0,s.jsx)(n.p,{children:"The daemon is still in its early stages of development. Therefore, the API is not stable and may change."})}),"\n",(0,s.jsx)(n.hr,{}),"\n",(0,s.jsx)(n.h4,{id:"usage-example",children:"Usage example"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-sh",children:'$ dart_frog daemon\n\n// ready event sent via stdout\n[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]\n\n// request inserted via stdin\n[{"method": "daemon.requestVersion", "id": "12"}]\n\n// response sent via stdout\n[{"id":"12","result":{"version":"0.0.1"}}]\n'})}),"\n",(0,s.jsxs)(n.p,{children:["The ",(0,s.jsx)(n.code,{children:"id"})," field on the request is used to match the request with the response. As the client sets it arbitrarily, the client is responsible for ensuring that all request ids are unique."]}),"\n",(0,s.jsx)(n.admonition,{type:"warning",children:(0,s.jsxs)(n.p,{children:["The requests should be strictly in the format ",(0,s.jsx)(n.code,{children:"[{...}]"}),". Therefore, sending a request with any of these formats: ",(0,s.jsx)(n.code,{children:"[{...},]"}),", ",(0,s.jsx)(n.code,{children:"[{...}, {...}]"})," or ",(0,s.jsx)(n.code,{children:"[{...}]\\n[{...}]"})," is currently not accepted."]})}),"\n",(0,s.jsx)(n.hr,{}),"\n",(0,s.jsx)(n.h1,{id:"domains",children:"Domains"}),"\n",(0,s.jsx)(n.p,{children:'To organize the accepted requests and its parameters as well as events, there are "domains." A\ndomain is a group of related requests and events.'}),"\n",(0,s.jsx)(n.p,{children:"The domains are:"}),"\n",(0,s.jsx)(l,{toc:x}),"\n",(0,s.jsxs)(n.h2,{id:"daemon-domain",children:[(0,s.jsx)(n.code,{children:"daemon"})," domain"]}),"\n",(0,s.jsxs)(n.p,{children:["The ",(0,s.jsx)(n.code,{children:"daemon"})," domain is used to manage the daemon itself."]}),"\n",(0,s.jsxs)(n.h3,{id:"method-requestversion",children:["Method: ",(0,s.jsx)(n.code,{children:"requestVersion"})]}),"\n",(0,s.jsx)(n.p,{children:"Request the daemon version."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Response"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsx)(n.tbody,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"version"}),(0,s.jsx)(n.td,{children:"string"}),(0,s.jsx)(n.td,{children:"The daemon version"})]})})]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-sh",children:'$ dart_frog daemon\n\n// ready event sent via stdout\n[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]\n\n// request inserted via stdin\n[{"method": "daemon.requestVersion", "id": "12"}]\n\n// response sent via stdout\n[{"id":"12","result":{"version":"0.0.1"}}]\n'})}),"\n",(0,s.jsxs)(n.h3,{id:"method-kill",children:["Method: ",(0,s.jsx)(n.code,{children:"kill"})]}),"\n",(0,s.jsx)(n.p,{children:"Shuts down the daemon"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Response"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsx)(n.tbody,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"message"}),(0,s.jsx)(n.td,{children:"string"}),(0,s.jsx)(n.td,{children:"A goodbye message"})]})})]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-sh",children:'$ dart_frog daemon\n\n// ready event sent via stdout\n[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]\n\n// request inserted via stdin\n[{"method": "daemon.kill", "id": "12"}]\n\n// response sent via stdout\n[{"id":"12","result":{"message":"Hogarth. You stay, I go. No following."}}]\n'})}),"\n",(0,s.jsxs)(n.h3,{id:"event-ready",children:["Event: ",(0,s.jsx)(n.code,{children:"ready"})]}),"\n",(0,s.jsx)(n.p,{children:"Signals that a daemon is ready right after startup"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Content"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"version"}),(0,s.jsx)(n.td,{children:"string"}),(0,s.jsx)(n.td,{children:"The daemon version"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"processId"}),(0,s.jsx)(n.td,{children:"int"}),(0,s.jsx)(n.td,{children:"The process id in which the daemon is running"})]})]})]}),"\n",(0,s.jsxs)(n.h2,{id:"dev_server-domain",children:[(0,s.jsx)(n.code,{children:"dev_server"})," domain"]}),"\n",(0,s.jsx)(n.p,{children:"Operations related to running/managing Dart Frog dev servers locally."}),"\n",(0,s.jsxs)(n.h3,{id:"method-start",children:["Method: ",(0,s.jsx)(n.code,{children:"start"})]}),"\n",(0,s.jsx)(n.p,{children:"Start a dev server on a given project."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Parameters"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"}),(0,s.jsx)(n.th,{children:"Required"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"workingDirectory"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The project directory"}),(0,s.jsx)(n.td,{children:"Yes"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"port"}),(0,s.jsx)(n.td,{children:"int"}),(0,s.jsx)(n.td,{children:"The port to run the dev server on"}),(0,s.jsx)(n.td,{children:"Yes"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"dartVmServicePort"}),(0,s.jsx)(n.td,{children:"int"}),(0,s.jsx)(n.td,{children:"The port to run the Dart VM Service on"}),(0,s.jsx)(n.td,{children:"Yes"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"hostname"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The hostname to run the dev server on"}),(0,s.jsx)(n.td,{children:"No"})]})]})]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Response"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsx)(n.tbody,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"applicationId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the dev server instance"})]})})]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-sh",children:'$ dart_frog daemon\n\n// ready event sent via stdout\n[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]\n\n// request inserted via stdin\n[{"method":"dev_server.start","id":"12","params":{"workingDirectory":"./","port":8080,"dartVmServicePort":8091}}]\n\n// response sent via stdout\n[{"event":"dev_server.applicationStarting","params":{"applicationId":"9e531349","requestId":"12"}}]\n\n// Few logs omitted\n'})}),"\n",(0,s.jsxs)(n.h3,{id:"method-reload",children:["Method: ",(0,s.jsx)(n.code,{children:"reload"})]}),"\n",(0,s.jsx)(n.p,{children:"Reload a running dev server."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Parameters"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"}),(0,s.jsx)(n.th,{children:"Required"})]})}),(0,s.jsx)(n.tbody,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"applicationId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The dev server identifier"}),(0,s.jsx)(n.td,{children:"Yes"})]})})]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Response"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsx)(n.tbody,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"applicationId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the dev server instance"})]})})]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-sh",children:'$ dart_frog daemon\n\n// ready event sent via stdout\n[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]\n\n// start server before reloading (use dev_server.start)\n\n// request inserted via stdin\n[{"method":"dev_server.reload","id":"12","params":{"applicationId":"9e531349"}}]\n\n// Few logs omitted\n\n// response sent via stdout\n[{"id":"12","result":{"applicationId":"9e531349"}}]\n\n// Few logs omitted\n'})}),"\n",(0,s.jsxs)(n.h3,{id:"method-stop",children:["Method: ",(0,s.jsx)(n.code,{children:"stop"})]}),"\n",(0,s.jsx)(n.p,{children:"Stop a running dev server."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Parameters"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"}),(0,s.jsx)(n.th,{children:"Required"})]})}),(0,s.jsx)(n.tbody,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"applicationId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The dev server identifier"}),(0,s.jsx)(n.td,{children:"Yes"})]})})]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Response"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"applicationId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the dev server instance"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"exitCode"}),(0,s.jsx)(n.td,{children:"int"}),(0,s.jsx)(n.td,{children:"The exit code of the dev server process"})]})]})]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-sh",children:'$ dart_frog daemon\n\n// ready event sent via stdout\n[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]\n\n// start server before stopping (use dev_server.start)\n\n// request inserted via stdin\n[{"method":"dev_server.stop","id":"12","params":{"applicationId":"9e531349"}}]\n\n// Few logs omitted\n\n// response sent via stdout\n[{"id":"12","result":{"applicationId":"9e531349","exitCode":0}}]\n'})}),"\n",(0,s.jsxs)(n.h3,{id:"event-applicationstarting",children:["Event: ",(0,s.jsx)(n.code,{children:"applicationStarting"})]}),"\n",(0,s.jsx)(n.p,{children:"Signals that a dev server is starting."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Content"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"applicationId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the dev server instance"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"requestId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the request that started the dev server"})]})]})]}),"\n",(0,s.jsxs)(n.h3,{id:"event-applicationexit",children:["Event: ",(0,s.jsx)(n.code,{children:"applicationExit"})]}),"\n",(0,s.jsx)(n.p,{children:"Signals that a dev server has exited."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Content"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"applicationId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the dev server instance"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"requestId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the request that started the dev server"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"exitCode"}),(0,s.jsx)(n.td,{children:"int"}),(0,s.jsx)(n.td,{children:"The exit code of the dev server process"})]})]})]}),"\n",(0,s.jsx)(n.h3,{id:"dev-server-logging-events",children:"Dev server logging events"}),"\n",(0,s.jsxs)(n.p,{children:['The dev server will send logging events to the client as they happen. These events are identified by\n"dev_server.logger<Severity>". See the ',(0,s.jsx)(n.a,{href:"#logging-events",children:"Logging events"})," section for more details."]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Content"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"applicationId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the dev server instance"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"requestId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the request that started the dev server"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"workingDirectory"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The project directory"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"message"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The log message"})]})]})]}),"\n",(0,s.jsxs)(n.h2,{id:"route_configuration-domain",children:[(0,s.jsx)(n.code,{children:"route_configuration"})," domain"]}),"\n",(0,s.jsx)(n.p,{children:"Operations related to the route configuration of a project."}),"\n",(0,s.jsxs)(n.p,{children:["A route configuration is generated from the files under ",(0,s.jsx)(n.code,{children:"routes"})," as it describes which routes are\navailable in the project as well as the location of middlewares. The route configuration is\nused to diagnose the project for issues such as rogue routes and path conflicts."]}),"\n",(0,s.jsxs)(n.h3,{id:"method-watcherstart",children:["Method: ",(0,s.jsx)(n.code,{children:"watcherStart"})]}),"\n",(0,s.jsx)(n.p,{children:"Starts a route configuration watcher for a given project. The watcher will send events to the client\nwhen the route configuration of a project changes."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Parameters"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"}),(0,s.jsx)(n.th,{children:"Required"})]})}),(0,s.jsx)(n.tbody,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"workingDirectory"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The project directory"}),(0,s.jsx)(n.td,{children:"Yes"})]})})]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Response"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsx)(n.tbody,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"watcherId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the watcher instance"})]})})]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-sh",children:'$ dart_frog daemon\n\n// ready event sent via stdout\n[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]\n\n// request inserted via stdin\n[{"method":"route_configuration.watcherStart","id":"12","params":{"workingDirectory":"./"}}]\n\n// response sent via stdout\n[{"id":"12","result":{"watcherId":"29f9ad21"}}]\n\n// An event is sent via stdout for every change detected\n[{"event":"route_configuration.changed","params":{"watcherId":"29f9ad21","requestId":"12","routeConfiguration":{ ... }}}]\n'})}),"\n",(0,s.jsxs)(n.h3,{id:"method-watcherstop",children:["Method: ",(0,s.jsx)(n.code,{children:"watcherStop"})]}),"\n",(0,s.jsxs)(n.p,{children:["Stops a route configuration watcher created by ",(0,s.jsx)(n.code,{children:"watcherStart"}),"."]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Parameters"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"}),(0,s.jsx)(n.th,{children:"Required"})]})}),(0,s.jsx)(n.tbody,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"watcherId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the watcher instance"}),(0,s.jsx)(n.td,{children:"Yes"})]})})]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Response"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"watcherId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the watcher instance"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"exitCode"}),(0,s.jsx)(n.td,{children:"int"}),(0,s.jsx)(n.td,{children:"The exit code of the watcher process"})]})]})]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-sh",children:'$ dart_frog daemon\n\n// ready event sent via stdout\n[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]\n\n// start watcher before stopping (use route_configuration.watcherStart)\n\n// request inserted via stdin\n[{"method":"route_configuration.watcherStop","id":"12","params":{"watcherId":"29f9ad21"}}]\n\n// Few logs omitted\n\n// response sent via stdout\n[{"id":"12","result":{"watcherId":"29f9ad21","exitCode":0}}]\n'})}),"\n",(0,s.jsxs)(n.h3,{id:"method-watchergeneraterouteconfiguration",children:["Method: ",(0,s.jsx)(n.code,{children:"watcherGenerateRouteConfiguration"})]}),"\n",(0,s.jsx)(n.p,{children:"Forces a route configuration watcher to generate a route configuration for a given project.\nAlso, returns the generated route configuration."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Parameters"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"}),(0,s.jsx)(n.th,{children:"Required"})]})}),(0,s.jsx)(n.tbody,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"watcherId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the watcher instance"}),(0,s.jsx)(n.td,{children:"Yes"})]})})]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Response"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"watcherId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the watcher instance"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"routeConfiguration"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The generated route configuration"})]})]})]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-sh",children:'$ dart_frog daemon\n\n// ready event sent via stdout\n[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]\n\n// start watcher before stopping (use route_configuration.watcherStart)\n\n// request inserted via stdin\n[{"method":"route_configuration.watcherGenerateRouteConfiguration","id":"12","params":{"watcherId":"29f9ad21"}}]\n\n// Few logs omitted\n\n// response sent via stdout\n[{"id":"12","result":{"watcherId":"29f9ad21","routeConfiguration":{ ... }}}]\n'})}),"\n",(0,s.jsxs)(n.h3,{id:"event-changed",children:["Event: ",(0,s.jsx)(n.code,{children:"changed"})]}),"\n",(0,s.jsx)(n.p,{children:"Signals that the route configuration of a project has changed."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Content"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"watcherId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the watcher instance"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"requestId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the request that started the watcher"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"routeConfiguration"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The generated route configuration"})]})]})]}),"\n",(0,s.jsxs)(n.h3,{id:"event-watcherstart",children:["Event: ",(0,s.jsx)(n.code,{children:"watcherStart"})]}),"\n",(0,s.jsx)(n.p,{children:"Signals that a route configuration watcher has started."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Content"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"watcherId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the watcher instance"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"requestId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the request"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"workingDirectory"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The project directory"})]})]})]}),"\n",(0,s.jsxs)(n.h3,{id:"event-watcherexit",children:["Event: ",(0,s.jsx)(n.code,{children:"watcherExit"})]}),"\n",(0,s.jsx)(n.p,{children:"Signals that a route configuration watcher has exited."}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Content"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"watcherId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the watcher instance"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"requestId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the request"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"workingDirectory"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The project directory"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"exitCode"}),(0,s.jsx)(n.td,{children:"int"}),(0,s.jsx)(n.td,{children:"The exit code of the watcher process"})]})]})]}),"\n",(0,s.jsx)(n.h3,{id:"route-configuration-watcher-logging-events",children:"Route configuration watcher logging events"}),"\n",(0,s.jsxs)(n.p,{children:['Each watcher instance will send logging events to the client as they happen. These events are identified by\n"route_configuration.logger<Severity>". See the ',(0,s.jsx)(n.a,{href:"#logging-events",children:"Logging events"})," section for more details."]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Content"}),":"]}),"\n"]}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"Field"}),(0,s.jsx)(n.th,{children:"Type"}),(0,s.jsx)(n.th,{children:"Description"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"watcherId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the watcher instance"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"requestId"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"A unique identifier for the request that started the watcher"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"workingDirectory"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The project directory"})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"message"}),(0,s.jsx)(n.td,{children:"String"}),(0,s.jsx)(n.td,{children:"The log message"})]})]})]}),"\n",(0,s.jsx)(n.h1,{id:"logging-events",children:"Logging events"}),"\n",(0,s.jsx)(n.p,{children:'Some operations (eg. starting a dev server) will generate logs. These logs are sent to the client\nvia logging events. These events are identified by the "logger" prefix on its name followed by its\nseverity. Its domain is always associated with the operation that generated the log.'}),"\n",(0,s.jsxs)(n.p,{children:["For example, this is logger event generate bhy the ",(0,s.jsx)(n.code,{children:"dev_server.start"})," operation\n(the content was formatted to improve readability):"]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-json",children:'[\n  {\n    "event": "dev_server.loggerInfo",\n    "params": {\n      "applicationId": "cfd5d56a-b855-49a7-9153-a035b1ba1bc4",\n      "requestId": "2",\n      "workingDirectory": "/path/to/project",\n      "message": "The Dart VM service is listening on http://127.0.0.1:8091/fWMHu3sTnYk=/"\n    }\n  }\n]\n'})}),"\n",(0,s.jsxs)(n.p,{children:["In this example, it is a logger event with the ",(0,s.jsx)(n.code,{children:"info"})," severity. The ",(0,s.jsx)(n.code,{children:"params"})," field contains the\nmetadata associated with the event. In this case, the ",(0,s.jsx)(n.code,{children:"applicationId"})," and ",(0,s.jsx)(n.code,{children:"requestId"})," fields\ncan be used to identify the operation that generated the log."]}),"\n",(0,s.jsx)(n.p,{children:"The available severities are:"}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"level"}),(0,s.jsx)(n.th,{children:"identification"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"debug"}),(0,s.jsx)(n.td,{children:(0,s.jsx)(n.code,{children:"loggerDetail"})})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"info"}),(0,s.jsxs)(n.td,{children:[(0,s.jsx)(n.code,{children:"loggerInfo"})," ",(0,s.jsx)("br",{})," ",(0,s.jsx)(n.code,{children:"loggerSuccess"}),(0,s.jsx)("br",{})," ",(0,s.jsx)(n.code,{children:"loggerWrite"})]})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"warn"}),(0,s.jsx)(n.td,{children:(0,s.jsx)(n.code,{children:"loggerWarning"})})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"error"}),(0,s.jsx)(n.td,{children:(0,s.jsx)(n.code,{children:"loggerError"})})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:"critical"}),(0,s.jsx)(n.td,{children:(0,s.jsx)(n.code,{children:"loggerAlert"})})]})]})]}),"\n",(0,s.jsx)(n.hr,{}),"\n",(0,s.jsx)(n.p,{children:'Associated with logging, there is also the progress loggings. These are used to signal the\nprogress of a long-running operation. For example, when generating server code. These events\nare identified by the "progress" prefix on its name. Its domain is always associated with the\noperation that generated the log. The identifiers are associated not with severity but with\nits progress. The available identifiers are:'}),"\n",(0,s.jsxs)(n.table,{children:[(0,s.jsx)(n.thead,{children:(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.th,{children:"identifier"}),(0,s.jsx)(n.th,{children:"details"})]})}),(0,s.jsxs)(n.tbody,{children:[(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:(0,s.jsx)(n.code,{children:"progressStart"})}),(0,s.jsxs)(n.td,{children:["Identifies the start of the progress. Its params include ",(0,s.jsx)(n.code,{children:"progressId"})," which can be used to track further events associated with this operation."]})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:(0,s.jsx)(n.code,{children:"progressUpdate"})}),(0,s.jsx)(n.td,{children:"Identifies an update on the progress."})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:(0,s.jsx)(n.code,{children:"progressCancel"})}),(0,s.jsx)(n.td,{children:"Progress was cancelled. Ends the progress."})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:(0,s.jsx)(n.code,{children:"progressFail"})}),(0,s.jsx)(n.td,{children:"Progress has failed. Ends the progress."})]}),(0,s.jsxs)(n.tr,{children:[(0,s.jsx)(n.td,{children:(0,s.jsx)(n.code,{children:"progressComplete"})}),(0,s.jsx)(n.td,{children:"Progress has completed. Ends the progress."})]})]})]})]})}function u(e={}){const{wrapper:n}={...(0,i.R)(),...e.components};return n?(0,s.jsx)(n,{...e,children:(0,s.jsx)(j,{...e})}):j(e)}},1021:(e,n,t)=>{t.d(n,{A:()=>g});var r=t(6540),s=t(3115);function i(e){const n=e.map((e=>({...e,parentIndex:-1,children:[]}))),t=Array(7).fill(-1);n.forEach(((e,n)=>{const r=t.slice(2,e.level);e.parentIndex=Math.max(...r),t[e.level]=n}));const r=[];return n.forEach((e=>{const{parentIndex:t,...s}=e;t>=0?n[t].children.push(s):r.push(s)})),r}function d(e){let{toc:n,minHeadingLevel:t,maxHeadingLevel:r}=e;return n.flatMap((e=>{const n=d({toc:e.children,minHeadingLevel:t,maxHeadingLevel:r});return function(e){return e.level>=t&&e.level<=r}(e)?[{...e,children:n}]:n}))}function c(e){const n=e.getBoundingClientRect();return n.top===n.bottom?c(e.parentNode):n}function l(e,n){let{anchorTopOffset:t}=n;const r=e.find((e=>c(e).top>=t));if(r){return function(e){return e.top>0&&e.bottom<window.innerHeight/2}(c(r))?r:e[e.indexOf(r)-1]??null}return e[e.length-1]??null}function h(){const e=(0,r.useRef)(0),{navbar:{hideOnScroll:n}}=(0,s.p)();return(0,r.useEffect)((()=>{e.current=n?0:document.querySelector(".navbar").clientHeight}),[n]),e}function o(e){const n=(0,r.useRef)(void 0),t=h();(0,r.useEffect)((()=>{if(!e)return()=>{};const{linkClassName:r,linkActiveClassName:s,minHeadingLevel:i,maxHeadingLevel:d}=e;function c(){const e=function(e){return Array.from(document.getElementsByClassName(e))}(r),c=function(e){let{minHeadingLevel:n,maxHeadingLevel:t}=e;const r=[];for(let s=n;s<=t;s+=1)r.push(`h${s}.anchor`);return Array.from(document.querySelectorAll(r.join()))}({minHeadingLevel:i,maxHeadingLevel:d}),h=l(c,{anchorTopOffset:t.current}),o=e.find((e=>h&&h.id===function(e){return decodeURIComponent(e.href.substring(e.href.indexOf("#")+1))}(e)));e.forEach((e=>{!function(e,t){t?(n.current&&n.current!==e&&n.current.classList.remove(s),e.classList.add(s),n.current=e):e.classList.remove(s)}(e,e===o)}))}return document.addEventListener("scroll",c),document.addEventListener("resize",c),c(),()=>{document.removeEventListener("scroll",c),document.removeEventListener("resize",c)}}),[e,t])}var a=t(6289),x=t(4848);function j(e){let{toc:n,className:t,linkClassName:r,isChild:s}=e;return n.length?(0,x.jsx)("ul",{className:s?void 0:t,children:n.map((e=>(0,x.jsxs)("li",{children:[(0,x.jsx)(a.A,{to:`#${e.id}`,className:r??void 0,dangerouslySetInnerHTML:{__html:e.value}}),(0,x.jsx)(j,{isChild:!0,toc:e.children,className:t,linkClassName:r})]},e.id)))}):null}const u=r.memo(j);function g(e){let{toc:n,className:t="table-of-contents table-of-contents__left-border",linkClassName:c="table-of-contents__link",linkActiveClassName:l,minHeadingLevel:h,maxHeadingLevel:a,...j}=e;const g=(0,s.p)(),p=h??g.tableOfContents.minHeadingLevel,v=a??g.tableOfContents.maxHeadingLevel,m=function(e){let{toc:n,minHeadingLevel:t,maxHeadingLevel:s}=e;return(0,r.useMemo)((()=>d({toc:i(n),minHeadingLevel:t,maxHeadingLevel:s})),[n,t,s])}({toc:n,minHeadingLevel:p,maxHeadingLevel:v});return o((0,r.useMemo)((()=>{if(c&&l)return{linkClassName:c,linkActiveClassName:l,minHeadingLevel:p,maxHeadingLevel:v}}),[c,l,p,v])),(0,x.jsx)(u,{toc:m,className:t,linkClassName:c,...j})}},8453:(e,n,t)=>{t.d(n,{R:()=>d,x:()=>c});var r=t(6540);const s={},i=r.createContext(s);function d(e){const n=r.useContext(i);return r.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(s):e.components||s:d(e.components),r.createElement(i.Provider,{value:n},e.children)}}}]);