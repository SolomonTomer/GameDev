// Renders svg/*.svg to ../../player/art/*.png with transparent backgrounds.
// Needs Node + Playwright with Chromium: NODE_PATH=$(npm root -g) node render.js
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const src = path.join(__dirname, 'svg');
const out = path.join(__dirname, '..', '..', 'player', 'art');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 224, height: 280 } });
  fs.mkdirSync(out, { recursive: true });
  for (const f of fs.readdirSync(src).filter(f => f.endsWith('.svg'))) {
    await page.setContent(`<html><body style="margin:0;background:transparent">${fs.readFileSync(path.join(src, f), 'utf8')}</body></html>`);
    await page.locator('svg').screenshot({ path: path.join(out, 'astronaut_' + f.replace('.svg', '.png')), omitBackground: true });
  }
  await browser.close();
})();
