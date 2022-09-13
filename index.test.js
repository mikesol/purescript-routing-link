let server;
describe("Conduit", () => {
	beforeAll(async () => {
		const app = require("express")();
		app.use(require("express-static")("dist/"));
		server = await app.listen(3000);
		await page.goto("http://localhost:3000/#/");
	});
	afterAll(async function () {
		// Cleanup
		await server.close();
	});

	it('should have the correct values', async () => {
		await page.waitForSelector("#clickhome");
		const clickHome = await page.$("#clickhome");
		await clickHome.click();
		await page.waitForSelector("#resfoo");
		const resfoo = await page.$("#resfoo");
		const valueFoo = await page.evaluate(el => el.textContent, resfoo)
		const clickFoo = await page.$("#clickfoo");
		await clickFoo.click();
		await page.waitForSelector("#resbar");
		const resbar = await page.$("#resbar");
		const valueBar = await page.evaluate(el => el.textContent, resbar)
		expect(valueBar).toMatch("Just true");
	});

});
