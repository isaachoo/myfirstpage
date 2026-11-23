/* 李節街宿舍 CMS demo bridge.
   Browser-only content preview. No authentication or server-side persistence. */
(function(){
  'use strict';
  var KEY='lch-cms-demo-v1';
  var data;
  try { data=JSON.parse(localStorage.getItem(KEY)||'null'); }catch(e){ return; }
  if(!data||!data.pages) return;
  var previewDraft=new URLSearchParams(location.search).get('cmsPreview')==='draft';
  var c=data.pages[previewDraft?'draft':'published'];
  if(!c) return;
  function pick(q){return document.querySelector(q)}
  function set(q,v){var el=pick(q);if(el&&typeof v==='string')el.textContent=v}
  function formatMultiline(el,value,accentFrom){
    if(!el||typeof value!=='string')return;
    el.replaceChildren();
    var lines=value.split('\n').filter(function(l){return l.trim()});
    lines.forEach(function(line,i){
      if(i>0)el.appendChild(document.createElement('br'));
      var node=document.createTextNode(line);
      if(accentFrom!==undefined&&i>=accentFrom){
        var em=document.createElement('em');em.appendChild(node);el.appendChild(em);
      }else el.appendChild(node);
    });
  }
  formatMultiline(pick('.hero h1'),c.heroTitle,2);
  set('.hero .hero-text',c.heroLead);
  formatMultiline(pick('#about h2'),c.aboutTitle);
  set('#about .about-intro',c.aboutBody);
  if(c.feeNon) set('#fees .fee-card.highlight strong', 'HK$'+Number(c.feeNon).toLocaleString('en-HK'));
  if(c.feeCssa) set('#fees .fee-card:not(.highlight) strong', 'HK$'+Number(c.feeCssa).toLocaleString('en-HK'));
  // Reinsert the /month labels when using textContent above.
  document.querySelectorAll('#fees .fee-card strong').forEach(function(el){
    var small=document.createElement('small'); small.textContent='/ 每月';el.appendChild(small);
  });
  if(c.address)set('.contact-card dd',c.address);
  if(c.phone){
    var tel=String(c.phone).replace(/[^0-9+]/g,'');
    document.querySelectorAll('a[href^="tel:"]').forEach(function(a){
      a.href='tel:'+tel;
      var t=a.textContent||'';
      a.textContent=t.includes('立即致電')?'立即致電 '+c.phone+' ↗':
        t.includes('2865 7590')?c.phone:t;
    });
    var dd=document.querySelectorAll('.contact-card dd');
    if(dd[1]){dd[1].replaceChildren();var link=document.createElement('a');link.href='tel:'+tel;link.textContent=c.phone;dd[1].appendChild(link);}
  }
  var media=previewDraft?data.media&&data.media.draft:data.media&&data.media.published;
  if(typeof media==='string'&&/^data:image\/(png|jpeg|webp);base64,/.test(media)){
    var scene=pick('.scene');
    if(scene){var illustration=pick('.scene-illustration');if(illustration)illustration.style.display='none';
      var img=document.createElement('img');img.src=media;img.alt='示範後台上載的圖片';img.style.cssText='position:absolute;inset:0;width:100%;height:100%;object-fit:cover;';scene.prepend(img);
    }
  }
  var items=(data.news||[]).map(function(x){return previewDraft?x.draft:x.live}).filter(function(x){return x&&x.title});
  if(items.length){
    var section=document.createElement('section');section.id='news';section.style.background='#eaf1ea';
    var wrap=document.createElement('div');wrap.className='container';
    var kicker=document.createElement('div');kicker.className='kicker';kicker.textContent='LATEST NEWS / 最新消息';
    var title=document.createElement('h2');title.textContent='最新消息';title.style.marginBottom='25px';
    var grid=document.createElement('div');grid.style.cssText='display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,260px),1fr));gap:16px';
    items.forEach(function(p){
      var a=document.createElement('article');a.style.cssText='background:#fff;border:1px solid #e1eae2;border-radius:14px;padding:24px';
      var date=document.createElement('small');date.textContent=previewDraft?'草稿預覽 · DEMO':'公告 · DEMO';date.style.cssText='color:#6c8976;font-weight:700';
      var heading=document.createElement('h3');heading.textContent=p.title;heading.style.cssText='margin:10px 0;color:#214d42';
      var para=document.createElement('p');para.textContent=p.summary||p.body||'';para.style.cssText='font-size:14px;color:#63746b;white-space:pre-line;margin:0';
      a.append(date,heading,para);grid.appendChild(a);
    });
    wrap.append(kicker,title,grid);section.appendChild(wrap);
    var target=pick('#facilities');if(target)target.parentNode.insertBefore(section,target);
    var nav=pick('#navigation');if(nav){var anchor=document.createElement('a');anchor.href='#news';anchor.textContent='最新消息';nav.insertBefore(anchor,nav.firstChild);}
  }
  if(previewDraft){
    var bar=document.createElement('div');bar.textContent='◉ CMS 草稿預覽 — 僅供示範，未發佈內容';bar.style.cssText='position:fixed;bottom:16px;left:16px;right:16px;max-width:520px;margin:auto;background:#fbe4a9;color:#3f3722;z-index:999;text-align:center;padding:10px 20px;border-radius:12px;box-shadow:0 8px 30px #0003;font-size:13px;font-weight:750';document.body.appendChild(bar);
  }
})();
