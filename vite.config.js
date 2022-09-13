const path = require("path");

export default {
	resolve: {
		alias: {
			PureScript: path.resolve(__dirname, 'output/Test.Main/'),
		},
	}
}
