const app = @import("app.zig");
const c = @import("c.zig");

pub fn getSurfFromText(text: app.Text) !c.SDL_Surface {
    // create cairo context
    const cr = createCairoContext(text.width, text.height);

    // paint bg color
    paintBackground(cr, text.bg.r, text.bg.g, text.bg.b);

    const layout = createPangoLayoutWithFont(cr, text.font);

    // paint text
    c.pango_layout_set_text(layout, text.content, -1);
    c.pango_cairo_show_layout(cr, layout);

    // render to SDL surface
    c.cairosdl_destroy(cr);

    return surface;
}

pub fn getSurfFromMarkup(markup: app.Markup) !*c.SDL_Surface {
    const surface = c.SDL_CreateRGBSurface(
        0,
        markup.width,
        markup.height,
        32,
        c.CAIROSDL_RMASK,
        c.CAIROSDL_GMASK,
        c.CAIROSDL_BMASK,
        c.CAIROSDL_AMASK,
    );

    // create cairo context
    const cr = c.cairosdl_create(surface).?;

    // paint bg color
    paintBackground(cr, markup.bg.r, markup.bg.g, markup.bg.b);

    const layout = c.pango_cairo_create_layout(cr);
    // paint text
    c.pango_layout_set_markup(layout, markup.content.ptr, -1);
    c.pango_cairo_show_layout(cr, layout);

    // render to SDL surface
    c.cairosdl_destroy(cr);

    return surface;
}

fn createPangoLayout(cr: *c.cairo_t) *c.PangoLayout {
    const layout = c.pango_cairo_create_layout(cr).?;
    return layout;
}

fn createPangoLayoutWithFont(cr: *c.cairo_t, font: []const u8) void {
    const layout = createPangoLayout(cr);
    const desc = c.pango_cairo_description_from_string(font);
    c.pango_layout_set_font_description(layout, desc);
}

fn createCairoContext(width: i32, height: i32) *c.cairo_t {
    const surface = createSurface(width, height);
    const cr = c.cairosdl_create(surface).?;
    return cr;
}

fn createSurface(width: i32, height: i32) *c.SDL_Surface {
    const surface = c.SDL_CreateRGBSurface(
        0,
        width,
        height,
        32,
        c.CAIROSDL_RMASK,
        c.CAIROSDL_GMASK,
        c.CAIROSDL_BMASK,
        c.CAIROSDL_AMASK,
    ).?;

    return surface;
}

fn paintBackground(cr: *c.cairo_t, r: f32, g: f32, b: f32) void {
    const surface = c.cairosdl_get_target(cr);
    c.cairo_set_source_rgb(cr, r, g, b);

    const w = @intToFloat(f64, surface.*.w);
    const h = @intToFloat(f64, surface.*.h);
    c.cairo_rectangle(cr, 0, 0, w, h);
    c.cairo_fill(cr);
}
