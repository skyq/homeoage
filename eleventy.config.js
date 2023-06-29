module.exports = function (c) {
    c.addPassthroughCopy('src/css');
    c.addPassthroughCopy('src/posts/**/*.(jpg|png|svg|mp4|avi|webm)');
    // Return your Object options:
    return {
        dir: {
            input: "src",
            output: "dist",
            layouts: 'layouts'
        }
    }
};
