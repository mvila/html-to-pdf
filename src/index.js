import Koa from 'koa';
import jsonError from 'koa-json-error';
import cors from '@koa/cors';
import body from 'koa-json-body';
import puppeteer from 'puppeteer';
import debugModule from 'debug';

const debug = debugModule('html-to-pdf');

const PORT = process.env.PORT || 3333;
const MARGIN = '25mm';

async function run() {
  const browser = await puppeteer.launch({args: ['--no-sandbox', '--disable-setuid-sandbox']});
  const page = await browser.newPage();

  const server = new Koa();

  server.use(jsonError());
  server.use(cors({maxAge: 900})); // 15 minutes
  server.use(body({limit: '32mb'}));

  server.use(async ctx => {
    if (ctx.method.toUpperCase() !== 'POST') {
      throw new Error('Invalid HTTP method');
    }

    if (ctx.path !== '/convert') {
      throw new Error('Invalid HTTP path');
    }

    const {html} = ctx.request.body || {};

    if (typeof html !== 'string') {
      throw new Error('Invalid HTTP body');
    }

    const start = Date.now();
    debug(`Handling request...`);

    await page.setContent(html);
    const pdf = await page.pdf({
      format: 'A4',
      margin: {top: MARGIN, right: MARGIN, bottom: MARGIN, left: MARGIN}
    });

    ctx.body = {pdf: pdf.toString('base64')};

    const duration = Date.now() - start;
    debug(`Request handled (duration: ${duration} ms)`);
  });

  server.listen(PORT).setTimeout(900 * 1000); // 15 minutes;

  console.log(`[INFO] Server started on port ${PORT}`);
}

run().catch(err => console.error(err));
