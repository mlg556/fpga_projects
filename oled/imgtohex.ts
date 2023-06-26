import * as pngs from "https://deno.land/x/pngs@0.1.1/mod.ts";

const image = await Deno.readFile("hilbert5.png")
const data = pngs.decode(image)

console.log(data)