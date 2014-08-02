(function(){var t,s,e,o={}.hasOwnProperty,r=function(t,s){function e(){this.constructor=t}for(var r in s)o.call(s,r)&&(t[r]=s[r]);return e.prototype=s.prototype,t.prototype=new e,t.__super__=s.prototype,t};e={},e.set_text=function(t,s){return t.innerText?t.innerText=s:t.textContent=s},e.add_events=function(t,s){var e,o,r,i;for(i=[],o=0,r=t.length;r>o;o++)e=t[o],i.push(null!=s?s.addEventListener(e.type,e.fn):document.addEventListener(e.type,e.fn));return i},e.remove_events=function(t,s){var e,o,r,i;for(i=[],o=0,r=t.length;r>o;o++)e=t[o],i.push(null!=s?s.removeEventListener(e.type,e.fn):document.removeEventListener(e.type,e.fn));return i},e.apply_styles=function(t,s){var e,o,r;r=[];for(e in s)o=s[e],r.push(t.style[e]=o);return r},e.extend=function(t,s){var e,o;null==t&&(t={}),null==s&&(s={});for(e in s)o=s[e],t[e]=o;return t},e.defaults=function(t,s){var e,o;null==s&&(s={});for(e in t)o=t[e],s.hasOwnProperty(e)||(s[e]=o);return s},t=function(){function t(s){this.opts=null!=s?s:{},this.setup_border_rulers(),this.setup_caliper(),this.setup_grid(),this.setup_mandolin(),this.mouse_tracker=t.MouseTracker.get_tracker(),this.setup_events(),"undefined"!=typeof console&&null!==console&&console.log("jrule ready!"),t.Messenger.alert("jrule ready!"),t.Messenger.alert('Press "h" to view help')}return t.talkative=1,t.version=.5,t.zIndex=999999,t.prototype.default_opts=function(){},t.prototype.destroy=function(){return this.caliper&&this.caliper.destroy(),this.border_rulers&&this.border_rulers.destroy(),this.grid&&this.grid.destroy(),this.mouse_tracker&&this.mouse_tracker.destroy(),this.mandolin&&this.mandolin.destroy(),document.jruler=void 0,"undefined"!=typeof console&&null!==console?console.log("Venni Vetti Vecci"):void 0},t.prototype.setup_events=function(){var s;return this.events||(this.events=[]),s=function(s){return function(e){return 67===e.keyCode?s.toggle_crosshairs():82===e.keyCode?s.toggle_rulers():71===e.keyCode?s.toggle_grid():72===e.keyCode?s.toggle_help():77===e.keyCode?(t.talkative=!t.talkative,t.Messenger.alert("Messages "+(t.talkative?"on":"off"),{duration:1e3,force:!0})):27===e.keyCode?s.destroy():void 0}}(this),this.events.push({type:"keydown",fn:s}),e.add_events(this.events)},t.prototype.setup_border_rulers=function(){return this.border_rulers=new t.BorderRulers},t.prototype.setup_caliper=function(){return this.caliper=new t.Caliper},t.prototype.setup_grid=function(){return this.grid=new t.Grid},t.prototype.setup_mandolin=function(){return this.mandolin=new t.Mandolin},t.prototype.toggle_crosshairs=function(){var s;return s=this.mouse_tracker.toggle_crosshairs(),t.Messenger.alert("Crosshairs "+(s?"on":"off"),{duration:1e3})},t.prototype.toggle_rulers=function(){var s;return s=this.border_rulers.toggle_visibility(),t.Messenger.alert("Rulers "+(s?"on":"off"),{duration:1e3})},t.prototype.toggle_grid=function(){var s;return s=this.grid.toggle_grid(),t.Messenger.alert("Grid "+(s?"on":"off"),{duration:1e3})},t.prototype.toggle_help=function(){return t.Help.get().toggle()},t}(),t.BorderRulers=function(){function s(s){this.opts=null!=s?s:{},this.rulers={},this.mouse_ticks={},this.mouse_tracker=t.MouseTracker.get_tracker(),this.default_opts(),this.setup_rulers(),this.setup_events()}return s.prototype.default_opts=function(){var t;return t={style:{backgroundColor:"#aaa",opacity:.5,tickColor:"#ccc",mouseTickColor:"#00f"},top:!0,left:!0,right:!1,bottom:!1,tick_distance:100,rule_size:25,divisions:8,show_mouse:!0,show_labels:!0,start_in_center:!0},this.opts=t},s.prototype.get_style=function(){return{backgroundColor:this.opts.style.backgroundColor,opacity:this.opts.style.opacity}},s.prototype.setup_rulers=function(s){var o,r,i,n,h,u,a;if(null==s&&(s=!1),!this.setup||s){this.setup&&s&&this.destroy(),o=function(s){return function(){var o,r;return o=document.createElement("div"),o.className="ruler",r=s.get_style(),e.extend(r,{position:"fixed",zIndex:t.zIndex}),e.apply_styles(o,r),o}}(this),this.opts.top&&(h=o(),e.apply_styles(h,{left:0,right:0,top:0,height:""+this.opts.rule_size+"px"}),this.rulers.top=h),this.opts.left&&(r=o(),e.apply_styles(r,{left:0,top:0,bottom:0,width:""+this.opts.rule_size+"px"}),this.rulers.left=r),u=this.rulers;for(i in u)n=u[i],null!=(a=document.body)&&a.appendChild(n);return this.setup_ticks(),this.shown=!0,this.setup=!0}},s.prototype.setup_events=function(){var t;return this.events||(this.events=[]),this.opts.show_mouse?(t=function(t){return function(s){return t.render()}}(this),this.events.push({type:"jrule:mousemove",fn:t}),e.add_events(this.events,document.body)):void 0},s.prototype.tick_style=function(t){var s;return s={position:"absolute",display:"block",backgroundColor:this.opts.style.tickColor},"top"===t||"bottom"===t?(s.width="1px",s.height="100%"):(s.width="100%",s.height="1px"),s},s.prototype.create_label=function(t,s){var o,r;return o=document.createElement("div"),o.className="tick_label",e.set_text(o,""+s+"px"),r={position:"absolute",fontSize:"10px",fontFamily:"sans-serif"},"top"===t?e.extend(r,{left:""+s+"px",bottom:"2px",marginLeft:"-14px"}):e.extend(r,{top:""+s+"px",left:"4px","-webkit-transform":"rotate(-90deg)",transform:"rotate(-90deg)","-moz-transform":"rotate(-90deg)"}),e.apply_styles(o,r),o},s.prototype.setup_ticks=function(){var s,o,r,i,n,h,u,a,p,c,l,d,_,y,f,m,v,k,g,x;for(r=document.body.getBoundingClientRect(),y=Math.ceil(r.width/this.opts.tick_distance),l=Math.round(r.width/y),o=Math.round(l/this.opts.divisions),g=["top","left"],f=0,k=g.length;k>f;f++)for(p=g[f],i=m=0;y>=0?y>m:m>y;i=y>=0?++m:--m)for(_=i*this.opts.tick_distance,this.draw_tick(p,_,1,{backgroundColor:"#666"}),this.opts.show_labels&&(d=this.create_label(p,_),this.rulers[p].appendChild(d)),n=v=1,x=this.opts.divisions;x>=1?x>v:v>x;n=x>=1?++v:--v)s=n*o+_,this.draw_tick(p,s,n%2?.3:.5);return this.opts.show_mouse?(this.rulers.hasOwnProperty("top")&&(u=this.create_tick("top",Math.round(r.width/2),1),u.style.backgroundColor=""+this.opts.style.mouseTickColor,this.mouse_ticks.x=u,this.rulers.top.appendChild(this.mouse_ticks.x)),this.rulers.hasOwnProperty("left")&&(a=this.create_tick("left",Math.round(r.width/2),1),a.style.backgroundColor=""+this.opts.style.mouseTickColor,this.mouse_ticks.y=a,this.rulers.left.appendChild(this.mouse_ticks.y)),h=document.createElement("div"),c={position:"fixed",zIndex:t.zIndex+1,left:0,top:0,padding:"6px",backgroundColor:"#888",color:"#fafafa",fontSize:"12px",fontFamily:"sans-serif",fontWeight:100},e.apply_styles(h,c),this.mouse_pos=h,document.body.appendChild(this.mouse_pos)):void 0},s.prototype.create_tick=function(t,s,o,r){var i,n;return null==o&&(o=1),null==r&&(r={}),i=document.createElement("div"),n=e.extend(this.tick_style(t),r),i.className="tick","top"===t||"bottom"===t?(n.left=""+s+"px",n.height=""+100*o+"%"):(n.top=""+s+"px",n.width=""+100*o+"%"),e.apply_styles(i,n),i},s.prototype.draw_tick=function(t,s,e,o){var r;return null==e&&(e=1),null==o&&(o={}),this.rulers.hasOwnProperty(t)?(r=this.create_tick(t,s,e,o),this.rulers[t].appendChild(r)):!1},s.prototype.destroy=function(){var t,s,o,r;e.remove_events(this.events,document.body),document.body.removeChild(this.mouse_pos),o=this.rulers,r=[];for(t in o)s=o[t],r.push(document.body.removeChild(s));return r},s.prototype.render=function(){return this.opts.show_mouse?(this.mouse_ticks.x&&(this.mouse_ticks.x.style.left=""+this.mouse_tracker.mousex+"px"),this.mouse_ticks.y&&(this.mouse_ticks.y.style.top=""+this.mouse_tracker.mousey+"px"),e.set_text(this.mouse_pos,""+this.mouse_tracker.mousex+", "+this.mouse_tracker.mousey)):void 0},s.prototype.toggle_visibility=function(){var t,s,e;this.shown=!this.shown,e=this.rulers;for(s in e)t=e[s],t.style.display=this.shown?"block":"none";return this.shown},s}(),t.Caliper=function(){function s(s){this.opts=null!=s?s:{},this.mouse_tracker=t.MouseTracker.get_tracker(),this.crosshairs=[],this.setup_events()}return s.prototype.setup_events=function(){var s,o;return this.events||(this.events=[]),s=function(s){return function(e){var o;return 16===e.keyCode?(s.measuring=!0,s.start_pos=[s.mouse_tracker.mousex,s.mouse_tracker.mousey],s.mark_spot_with_crosshair(s.start_pos),document.body.style.cursor="none",s.setup_indicators(),o=function(){return s.measuring=!1,s.end_pos=[s.mouse_tracker.mousex,s.mouse_tracker.mousey],s.last_size=[Math.abs(s.end_pos[0]-s.start_pos[0]),Math.abs(s.end_pos[1]-s.start_pos[1])],t.Messenger.alert(""+s.last_size[0]+"x"+s.last_size[1]),document.removeEventListener("keyup",o),s.cleanup()},document.addEventListener("keyup",o)):void 0}}(this),this.events.push({type:"keydown",fn:s}),o=function(t){return function(){return t.render()}}(this),this.events.push({type:"jrule:mousemove",fn:o}),e.add_events([{type:"keydown",fn:s}]),e.add_events([{type:"jrule:mousemove",fn:o}],document.body)},s.prototype.render=function(){var s,o,r,i,n,h,u,a;return this.measuring?(u=Math.min(this.mouse_tracker.mousex,this.start_pos[0]),a=Math.min(this.mouse_tracker.mousey,this.start_pos[1]),h=Math.max(this.mouse_tracker.mousex,this.start_pos[0])-Math.min(this.mouse_tracker.mousex,this.start_pos[0]),o=Math.max(this.mouse_tracker.mousey,this.start_pos[1])-Math.min(this.mouse_tracker.mousey,this.start_pos[1]),i={width:""+h+"px",height:""+o+"px",left:""+u+"px",top:""+a+"px",zIndex:t.zIndex},e.apply_styles(this.indicator,i),r={display:"block"},s=this.start_pos[0]>this.mouse_tracker.mousex?"left":"right",n=this.start_pos[1]>this.mouse_tracker.mousey?"up":"down",this.drag_direction=[s,n],"left"===s?(r.left=0,r.right="auto"):(r.right=0,r.left="auto"),"up"===n?(r.top=0,r.bottom="auto"):(r.bottom=0,r.top="auto"),e.apply_styles(this.indicator_size,r),e.set_text(this.indicator_size,""+h+", "+o)):void 0},s.prototype.setup_indicators=function(){var s,o,r,i;return o=document.createElement("div"),s={position:"fixed",left:""+this.start_pos[0]+"px",top:""+this.start_pos[1]+"px",backgroundColor:"rgba(100, 100, 100, .4)",zIndex:t.zIndex},this.indicator=o,e.apply_styles(this.indicator,s),document.body.appendChild(this.indicator),r=document.createElement("div"),i={position:"absolute",right:0,bottom:0,fontFamily:"sans-serif",fontSize:"12px",backgroundColor:"#000",color:"#fff",padding:"3px",zIndex:1},this.indicator_size=r,e.apply_styles(this.indicator_size,i),this.indicator.appendChild(this.indicator_size)},s.prototype.mark_spot_with_crosshair=function(s){var e,o,r,i,n;for(this.crosshairs.push(t.Crosshair.create("x",""+s[0]+"px")),this.crosshairs.push(t.Crosshair.create("y",""+s[1]+"px")),i=this.crosshairs,n=[],o=0,r=i.length;r>o;o++)e=i[o],n.push(document.body.appendChild(e));return n},s.prototype.cleanup=function(){var t,s,e,o;for(this.indicator.removeChild(this.indicator_size),document.body.removeChild(this.indicator),o=this.crosshairs,s=0,e=o.length;e>s;s++)t=o[s],document.body.removeChild(t);return this.crosshairs=[],document.body.style.cursor="default"},s.prototype.destroy=function(){var t,s,o,r,i,n;for(s=null,o=null,n=this.events,r=0,i=n.length;i>r;r++)t=n[r],"keydown"===t.type&&(s=t),"jrule:mousemove"===t.type&&(o=t);return s&&e.remove_events([{type:"keydown",fn:s.fn}]),o?e.remove_events([{type:"jrule:mousemove",fn:o.fn}],document.body):void 0},s}(),t.Crosshair=function(){function s(){}return s.create=function(s,o,r){var i,n,h,u,a;null==o&&(o="50%"),null==r&&(r={}),h={crosshairColor:"rgba(100, 100, 100, .5)",crosshairThickness:1};for(n in h)a=h[n],r.hasOwnProperty(n)||(r[n]=a);return i=document.createElement("div"),u={position:"fixed",backgroundColor:""+r.crosshairColor,zIndex:t.zIndex},i.className="crosshair","x"===s||"horizontal"===s?e.extend(u,{width:""+r.crosshairThickness+"px",top:0,bottom:0,left:""+o}):e.extend(u,{height:""+r.crosshairThickness+"px",left:0,right:0,top:""+o}),e.apply_styles(i,u),i},s}(),t.Grid=function(){function s(t){this.opts=null!=t?t:{},this.default_opts(),this.setup_grid(),this.setup_events()}return s.prototype.default_opts=function(){var t,s,e,o,r,i;t={tick_distance:100,divisions:3,show:!1,start_in_center:!0,style:{tickLineColor:"rgba(191, 231, 243, .6)",divisionLineColor:"rgba(220, 220, 220, .3)",centerLineColor:"rgba(255, 0, 0, .3)"}};for(s in t)if(o=t[s],this.opts.hasOwnProperty(s)){if("object"==typeof this.opts[s]){i=this.opts[s];for(e in i)r=i[e],this.opts[s].hasOwnProperty(e)||(this.opts[s][s]=r)}}else this.opts[s]=o;return this.opts},s.prototype.setup_events=function(){var t;return this.events||(this.events=[]),this.window_resizing=!1,this.resize_to=null,t=function(t){return function(s){return t.window_resizing?(t.resize_to&&clearTimeout(t.resize_to),t.resize_to=setTimeout(function(){return t.window_resizing=!1,t.setup_grid(),t.show_ticks()},400)):(t.window_resizing=!0,t.cleanup())}}(this),e.add_events(this.events,window)},s.prototype.setup_grid=function(){var s,e,o,r,i,n,h,u,a,p,c,l,d,_,y,f,m,v,k,g;if(s=Math.round(document.documentElement.clientWidth/2),e=Math.round(document.documentElement.clientHeight/2),n=Math.ceil(document.documentElement.clientWidth/this.opts.tick_distance),o=this.opts.divisions>0?Math.round(this.opts.tick_distance/this.opts.divisions):0,this.ticks=[],this.opts.start_in_center&&(n/=2,this.ticks.push(t.Crosshair.create("x",""+s+"px",{crosshairColor:this.opts.style.centerLineColor})),this.ticks.push(t.Crosshair.create("y",""+e+"px",{crosshairColor:this.opts.style.centerLineColor})),this.opts.divisions>0))for(i=c=1,m=this.opts.divisions;m>=1?m>c:c>m;i=m>=1?++c:--c)this.ticks.push(t.Crosshair.create("x",""+(s+i*o)+"px",{crosshairColor:this.opts.style.divisionLineColor})),this.ticks.push(t.Crosshair.create("y",""+(e+i*o)+"px",{crosshairColor:this.opts.style.divisionLineColor})),this.ticks.push(t.Crosshair.create("x",""+(s-i*o)+"px",{crosshairColor:this.opts.style.divisionLineColor})),this.ticks.push(t.Crosshair.create("y",""+(e-i*o)+"px",{crosshairColor:this.opts.style.divisionLineColor}));for(r=l=1;n>=1?n>l:l>n;r=n>=1?++l:--l){if(h=r*this.opts.tick_distance,a=this.opts.start_in_center?s+h:h,p=this.opts.start_in_center?e+h:h,this.ticks.push(t.Crosshair.create("x",""+a+"px",{crosshairColor:this.opts.style.tickLineColor})),this.ticks.push(t.Crosshair.create("y",""+p+"px",{crosshairColor:this.opts.style.tickLineColor})),this.opts.divisions>0)for(i=d=1,v=this.opts.divisions;v>=1?v>d:d>v;i=v>=1?++d:--d)this.ticks.push(t.Crosshair.create("x",""+(a+i*o)+"px",{crosshairColor:this.opts.style.divisionLineColor})),this.ticks.push(t.Crosshair.create("y",""+(p+i*o)+"px",{crosshairColor:this.opts.style.divisionLineColor}));if(this.opts.start_in_center&&(this.ticks.push(t.Crosshair.create("x",""+(s-h)+"px",{crosshairColor:this.opts.style.tickLineColor})),this.ticks.push(t.Crosshair.create("y",""+(e-h)+"px",{crosshairColor:this.opts.style.tickLineColor})),this.opts.divisions>0))for(i=_=1,k=this.opts.divisions;k>=1?k>_:_>k;i=k>=1?++_:--_)this.ticks.push(t.Crosshair.create("x",""+(s-h-i*o)+"px",{crosshairColor:this.opts.style.divisionLineColor})),this.ticks.push(t.Crosshair.create("y",""+(e-h-i*o)+"px",{crosshairColor:this.opts.style.divisionLineColor}))}for(g=this.ticks,f=0,y=g.length;y>f;f++)u=g[f],document.body.appendChild(u);return this.opts.show?this.show_ticks():this.hide_ticks()},s.prototype.cleanup=function(){var t,s,e,o,r;for(o=this.ticks,r=[],s=0,e=o.length;e>s;s++)t=o[s],r.push(document.body.removeChild(t));return r},s.prototype.hide_ticks=function(){var t,s,e,o,r;for(this.shown=!1,o=this.ticks,r=[],s=0,e=o.length;e>s;s++)t=o[s],r.push(t.style.display="none");return r},s.prototype.show_ticks=function(){var t,s,e,o,r;for(this.shown=!0,o=this.ticks,r=[],s=0,e=o.length;e>s;s++)t=o[s],r.push(t.style.display="block");return r},s.prototype.toggle_grid=function(){return this.shown=!this.shown,this.shown?this.show_ticks():this.hide_ticks(),this.shown},s.prototype.destroy=function(){return this.cleanup(),e.remove_events(this.events,window)},s}(),t.Mandolin=function(){function s(s){this.opts=null!=s?s:{},this.slices=[],this.tracker=t.MouseTracker.get_tracker(),this.default_opts(),this.setup_events()}return s.prototype.default_opts=function(){var t;return t={snap:!1,snap_to:10,style:{sliceColor:"rgba(150, 150, 150, .5)"}},this.opts=e.defaults(t,this.opts)},s.prototype.setup_events=function(){var t;return this.events||(this.events=[]),t=function(t){return function(s){return 83===s.keyCode?t.create_slice_at_mouse():68===s.keyCode?t.create_divide_at_mouse():void 0}}(this),this.events.push({type:"keydown",fn:t}),e.add_events(this.events)},s.prototype.get_snap_for=function(t){var s,e,o;for(e=t,o=t%this.opts.snap_to===0,s=0;!o;)s+=1,(t+s)%this.opts.snap_to===0?(e=t+s,o=!0):(t-s)%this.opts.snap_to===0&&(e=t-s,o=!0);return e},s.prototype.create_slice=function(s){var e;return this.opts.snap&&(s=this.get_snap_for(s)),e=t.Crosshair.create("x",""+s+"px",{backgroundColor:this.opts.style.sliceColor}),t.Messenger.alert("Slice created at "+s+"px"),document.body.appendChild(e),this.slices.push(e)},s.prototype.create_divide=function(s){var e;return this.opts.snap&&(s=this.get_snap_for(s)),e=t.Crosshair.create("y",""+s+"px",{backgroundColor:this.opts.style.sliceColor}),t.Messenger.alert("Divide created at "+s+"px"),document.body.appendChild(e),this.slices.push(e)},s.prototype.create_slice_at_mouse=function(){return this.create_slice(this.tracker.mousex)},s.prototype.create_divide_at_mouse=function(){return this.create_divide(this.tracker.mousey)},s.prototype.clear_slices=function(){var t,s,e,o;for(o=this.slices,s=0,e=o.length;e>s;s++)t=o[s],document.body.removeChild(t);return this.slices=[]},s.prototype.hide_slices=function(){var t,s,e,o,r;for(o=this.slices,r=[],s=0,e=o.length;e>s;s++)t=o[s],r.push(t.style.display="none");return r},s.prototype.show_slices=function(){var t,s,e,o,r;for(o=this.slices,r=[],s=0,e=o.length;e>s;s++)t=o[s],r.push(t.style.display="block");return r},s.prototype.destroy=function(){return this.clear_slices(),e.remove_events(this.events)},s}(),t.Messenger=function(){function s(t){this.opts=null!=t?t:{},this.container=null,this.default_opts(),this.create(),this.setup_events()}return s.alert=function(s,o){var r,i,n,h,u,a,p;if(null==o&&(o={}),(t.talkative||o.force)&&(this.message_stack||(this.message_stack=[]),this.message_stack.push(new t.Messenger(e.extend({content:s,is_flash:!0},o))),this.message_stack.length>1)){for(h=36,n=!1,p=this.message_stack,r=u=0,a=p.length;a>u;r=++u)i=p[r],i?i.visible?(i.container.style.top=""+h+"px",h+=i.container.clientHeight+6):i.destroyed&&(delete this.message_stack[r],n=!0):n=!0;if(n)return this.cleanup_message_stack()}},s.cleanup_message_stack=function(){var t,s,e,o,r;for(t=[],r=this.message_stack,e=0,o=r.length;o>e;e++)s=r[e],s&&!s.destroyed&&t.push(s);return this.message_stack=t},s.prototype.setup_events=function(){var t;return this.events||(this.events=[]),this.container?(t=function(t){return function(s){return s.preventDefault(),t.hide()}}(this),this.events.push({type:"click",fn:t}),e.add_events(this.events,this.container)):void 0},s.prototype.default_opts=function(){var t;return t={content:"",html_content:!1,duration:5e3,show:!0,is_flash:!1,type:"",colors:{alert:"rgba(0, 0, 0, .75)",error:"rgba(0, 0, 0, .75)"}},this.opts=e.defaults(t,this.opts)},s.prototype.create=function(){var s,o;return s=document.createElement("div"),s.className="message "+this.opts.type,o={position:"fixed",top:"36px",right:"10px",padding:"8px 12px",backgroundColor:"rgba(0, 0, 0, .8)",color:"#fff",display:"none",zIndex:t.zIndex+10,fontSize:"14px",fontFamily:"sans-serif",borderRadius:"3px",maxWidth:"300px",cursor:"pointer"},this.opts.colors.hasOwnProperty(this.opts.type)&&(o.backgroundColor=this.opts.colors[this.opts.type]),e.apply_styles(s,o),this.opts.html_content?s.innerHTML=this.opts.html_content:e.set_text(s,this.opts.content),this.container=s,document.body.appendChild(this.container),this.opts.show?this.show():void 0},s.prototype.show=function(){return this.container||this.create(),this.container.style.display="block",this.visible=!0,this.opts.duration?this.timeout=setTimeout(function(t){return function(){return t.hide()}}(this),this.opts.duration):void 0},s.prototype.hide=function(){return this.visible=!1,this.container.style.display="none",this.timeout&&clearTimeout(this.timeout),this.opts.is_flash?this.destroy():void 0},s.prototype.toggle=function(){return this.visible?this.hide():this.show()},s.prototype.destroy=function(){return document.body.removeChild(this.container),this.destroyed=!0,e.remove_events(this.events,this.container)},s}(),t.Help=function(s){function o(){return o.__super__.constructor.apply(this,arguments)}return r(o,s),o.get=function(){return this.help||(this.help=new t.Help)},o.prototype.default_opts=function(){var t;return t="Welcome to JRule! Thanks for using it. <br><br> JRule helps you measure and line things up. It's simple to use, here are some controls: <br> Press 'c' to toggle the Crosshairs<br> Press 'g' to toggle the Grid<br> Press 'r' to toggle the Rulers<br> Hold 'shift' and move the mouse to Measure<br> Press 'h' to see this message again<br> Click this message to get rid of it<br> Press 'escape' to remove JRule when you're done<br>",e.extend(o.__super__.default_opts.apply(this,arguments),{html_content:t,is_flash:!1,show:!1,duration:0})},o}(t.Messenger),t.MouseTracker=function(){function s(t){this.opts=null!=t?t:{},this.crosshairs=null,this.default_opts(),this.setup_events(),this.opts.show_crosshairs&&this.setup_crosshairs()}return s.get_tracker=function(){return this.tracker||(this.tracker=new t.MouseTracker)},s.prototype.default_opts=function(){var t;return t={show_crosshairs:!0,style:{crosshairColor:"rgba(100, 100, 100, .6)",crosshairThickness:1}},e.defaults(t,this.opts)},s.prototype.setup_events=function(){var t,s;return this.events||(this.events=[]),s=function(t){return function(s){var e;return t.mousex=s.clientX,t.mousey=s.clientY,e=new Event("jrule:mousemove"),document.body.dispatchEvent(e),t.opts.show_crosshairs?t.render_crosshairs():void 0}}(this),this.events.push({type:"mousemove",fn:s}),t=function(t){return function(s){return 187===s.keyCode?t.increase_crosshair_size():189===s.keyCode?t.decrease_crosshair_size():void 0}}(this),this.events.push({type:"keydown",fn:t}),e.add_events(this.events)},s.prototype.increase_crosshair_size=function(){var s,e;return this.opts.style.crosshairThickness+=1,null!=(s=this.crosshairs.x)&&(s.style.width=""+this.opts.style.crosshairThickness+"px"),null!=(e=this.crosshairs.y)&&(e.style.height=""+this.opts.style.crosshairThickness+"px"),t.Messenger.alert(""+this.opts.style.crosshairThickness+"px",{duration:600})},s.prototype.decrease_crosshair_size=function(){var s,e;return this.opts.style.crosshairThickness=Math.max(1,this.opts.style.crosshairThickness-1),null!=(s=this.crosshairs.x)&&(s.style.width=""+this.opts.style.crosshairThickness+"px"),null!=(e=this.crosshairs.y)&&(e.style.height=""+this.opts.style.crosshairThickness+"px"),t.Messenger.alert(""+this.opts.style.crosshairThickness+"px",{duration:600})},s.prototype.setup_crosshairs=function(){var s,e,o,r;this.crosshairs={},this.crosshairs.x=t.Crosshair.create("x","50%",this.opts.style),this.crosshairs.y=t.Crosshair.create("y","50%",this.opts.style),o=this.crosshairs,r=[];for(e in o)s=o[e],r.push(document.body.appendChild(s));return r},s.prototype.render_crosshairs=function(){var t;return this.crosshairs||this.setup_crosshairs(),t=1===this.opts.style.crosshairThickness?0:Math.round(this.opts.style.crosshairThickness/2),this.crosshairs.x.style.left=""+(this.mousex-t)+"px",this.crosshairs.y.style.top=""+(this.mousey-t)+"px"},s.prototype.toggle_crosshairs=function(){return this.opts.show_crosshairs=!this.opts.show_crosshairs,this.opts.show_crosshairs||this.remove_crosshairs(),this.opts.show_crosshairs},s.prototype.remove_crosshairs=function(){var t,s,e;e=this.crosshairs;for(s in e)t=e[s],document.body.removeChild(t);return this.crosshairs=null},s.prototype.destroy=function(){return this.remove_crosshairs(),e.remove_events(this.events)},s}(),document.JRule=t,s=function(){return document.jruler=new document.JRule},"complete"!==document.readyState?document.addEventListener("DOMContentLoaded",function(){return s()}):s()}).call(this);