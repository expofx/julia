### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 363f32d6-a758-47b8-8ea4-b71552e191e4
begin
	import Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ a78de663-bb10-437c-a2a3-46b662414ca0
begin
	Pkg.add(["Images", "ImageMagick"])
	using Images
end

# ╔═╡ b6434fca-c3dd-4d93-b4ba-84e6062acb92
begin
	Pkg.add("PlutoUI")
	using PlutoUI
end

# ╔═╡ bfd8d202-86b1-4b1b-8b0b-466226365636
function camera_input(;max_size=200, default_url="https://i.imgur.com/SUmi94P.png")
"""
<span class="pl-image waiting-for-permission">
<style>
	
	.pl-image.popped-out {
		position: fixed;
		top: 0;
		right: 0;
		z-index: 5;
	}

	.pl-image #video-container {
		width: 250px;
	}

	.pl-image video {
		border-radius: 1rem 1rem 0 0;
	}
	.pl-image.waiting-for-permission #video-container {
		display: none;
	}
	.pl-image #prompt {
		display: none;
	}
	.pl-image.waiting-for-permission #prompt {
		width: 250px;
		height: 200px;
		display: grid;
		place-items: center;
		font-family: monospace;
		font-weight: bold;
		text-decoration: underline;
		cursor: pointer;
		border: 5px dashed rgba(0,0,0,.5);
	}

	.pl-image video {
		display: block;
	}
	.pl-image .bar {
		width: inherit;
		display: flex;
		z-index: 6;
	}
	.pl-image .bar#top {
		position: absolute;
		flex-direction: column;
	}
	
	.pl-image .bar#bottom {
		background: black;
		border-radius: 0 0 1rem 1rem;
	}
	.pl-image .bar button {
		flex: 0 0 auto;
		background: rgba(255,255,255,.8);
		border: none;
		width: 2rem;
		height: 2rem;
		border-radius: 100%;
		cursor: pointer;
		z-index: 7;
	}
	.pl-image .bar button#shutter {
		width: 3rem;
		height: 3rem;
		margin: -1.5rem auto .2rem auto;
	}

	.pl-image video.takepicture {
		animation: pictureflash 200ms linear;
	}

	@keyframes pictureflash {
		0% {
			filter: grayscale(1.0) contrast(2.0);
		}

		100% {
			filter: grayscale(0.0) contrast(1.0);
		}
	}
</style>

	<div id="video-container">
		<div id="top" class="bar">
			<button id="stop" title="Stop video">✖</button>
			<button id="pop-out" title="Pop out/pop in">⏏</button>
		</div>
		<video playsinline autoplay></video>
		<div id="bottom" class="bar">
		<button id="shutter" title="Click to take a picture">📷</button>
		</div>
	</div>
		
	<div id="prompt">
		<span>
		Enable webcam
		</span>
	</div>

<script>
	// based on https://github.com/fonsp/printi-static (by the same author)
	const span = (this?.currentScript ?? currentScript).parentElement
	const video = span.querySelector("video")
	const popout = span.querySelector("button#pop-out")
	const stop = span.querySelector("button#stop")
	const shutter = span.querySelector("button#shutter")
	const prompt = span.querySelector(".pl-image #prompt")

	const maxsize = $(max_size)

	const send_source = (source, src_width, src_height) => {
		const scale = Math.min(1.0, maxsize / src_width, maxsize / src_height)

		const width = Math.floor(src_width * scale)
		const height = Math.floor(src_height * scale)

		const canvas = html`<canvas width=\${width} height=\${height}>`
		const ctx = canvas.getContext("2d")
		ctx.drawImage(source, 0, 0, width, height)

		span.value = {
			width: width,
			height: height,
			data: ctx.getImageData(0, 0, width, height).data,
		}
		span.dispatchEvent(new CustomEvent("input"))
	}
	
	const clear_camera = () => {
		window.stream.getTracks().forEach(s => s.stop());
		video.srcObject = null;

		span.classList.add("waiting-for-permission");
	}

	prompt.onclick = () => {
		navigator.mediaDevices.getUserMedia({
			audio: false,
			video: {
				facingMode: "environment",
			},
		}).then(function(stream) {

			stream.onend = console.log

			window.stream = stream
			video.srcObject = stream
			window.cameraConnected = true
			video.controls = false
			video.play()
			video.controls = false

			span.classList.remove("waiting-for-permission");

		}).catch(function(error) {
			console.log(error)
		});
	}
	stop.onclick = () => {
		clear_camera()
	}
	popout.onclick = () => {
		span.classList.toggle("popped-out")
	}

	shutter.onclick = () => {
		const cl = video.classList
		cl.remove("takepicture")
		void video.offsetHeight
		cl.add("takepicture")
		video.play()
		video.controls = false
		console.log(video)
		send_source(video, video.videoWidth, video.videoHeight)
	}
	
	
	document.addEventListener("visibilitychange", () => {
		if (document.visibilityState != "visible") {
			clear_camera()
		}
	})


	// Set a default image

	const img = html`<img crossOrigin="anonymous">`

	img.onload = () => {
	console.log("helloo")
		send_source(img, img.width, img.height)
	}
	img.src = "$(default_url)"
	console.log(img)
</script>
</span>
""" |> HTML
end

# ╔═╡ fddd9677-a3c3-4d1b-8520-2bf984b69f5d
image_file = download("https://i.imgur.com/bIRGzVOb.jpg")

# ╔═╡ 6e6aa95c-c304-43bc-94a1-704cc8fce4ee
### To take a picture ###

# @bind raw_camera_data camera_input(;max_size=100)
# camera_image = process_raw_camera_data(raw_camera_data);

# ╔═╡ 4e0757c2-2267-43cd-a310-23294fffe1b3

function process_raw_camera_data(raw_camera_data)

	reds_flat = UInt8.(raw_camera_data["data"][1:4:end])
	greens_flat = UInt8.(raw_camera_data["data"][2:4:end])
	blues_flat = UInt8.(raw_camera_data["data"][3:4:end])

	width = raw_camera_data["width"]
	height = raw_camera_data["height"]

	reds = reshape(reds_flat, (width, height))' / 255.0
	greens = reshape(greens_flat, (width, height))' / 255.0
	blues = reshape(blues_flat, (width, height))' / 255.0
	
	RGB.(reds, greens, blues)
end

# ╔═╡ c50fcdc5-3bad-4ac9-baa4-8b171deb92f0
image = Images.load(image_file)

# ╔═╡ 34af6aa6-5933-46d6-ac6e-889e8667fad0
md"""Decimate"""

# ╔═╡ 6b51f016-73ad-40d5-a6a0-121a63c1f370
decimate(image, ratio=5) = image[1:ratio:end, 1:ratio:end]

# ╔═╡ 89d9a367-cedd-4065-9748-aceb42591fd8
@bind dec Slider(1:25, show_value=true)

# ╔═╡ 9fc41f76-5ae2-4a10-af4c-fd05a3394c8e
decimated_image = decimate(image, dec)

# ╔═╡ f7421afa-58b1-4a73-831b-07d21eefda13
md"""Normalize"""

# ╔═╡ babab1f3-acfe-4e40-9db0-6928a62ba986
function mean(x)
	return sum(x)/length(x)
end

# ╔═╡ 93104e3c-e6fe-42b1-82c4-8a5731d6c01b
mean(image)

# ╔═╡ e7643df0-92d7-450f-a6f9-978ddf4321d9
size(image)

# ╔═╡ bedcd25c-66c2-4efc-aca8-5fdb8d70c3ba
length(image)

# ╔═╡ d2fe1c60-a2cc-42d8-af58-a7a1eec4cdff
function normalize(image)
	image.-mean(image)
end

# ╔═╡ 345f5783-ca7b-4b93-b729-84587e713fb4
image_mean = normalize(image)

# ╔═╡ 0ee499b1-4af8-4695-86d1-54fae5f9232e
md"""Quantize"""

# ╔═╡ ca8c9a51-83d9-41de-af45-d573766142e0
begin
	function quantize(x::Number)
		return floor(10x)/10
	end
	
	function quantize(color::AbstractRGB)
		return RGB(quantize(color.r), quantize(color.g), quantize(color.b))
	end
	
	function quantize(image::AbstractMatrix)
		return quantize.(image)
	end
end

# ╔═╡ 91354607-e728-4b44-bc68-f9fb856678dd
image_quantize = quantize(image)

# ╔═╡ 9a2fc770-1c18-4dcc-a6db-02dee026aee3
md"""Invert"""

# ╔═╡ 64fdf308-836b-42f1-a2df-822c4605d2f9
begin
	function invert(color::AbstractRGB)
		return RGB(1-color.r, 1-color.g, 1-color.b)
	end
	
	function invert(image::AbstractMatrix)
		return invert.(image)
	end
end

# ╔═╡ 95bde916-34cc-494e-b0fc-72b90d951408
image_invert = invert(image)

# ╔═╡ a0b2b8ce-222d-472f-9ae2-2ebdd3166612
md"""Noise"""

# ╔═╡ 5ed829b7-2c51-4739-bb35-b64085ae99cc
begin
	function noise(x::Number, s)
		return x+s*rand()
	end
	
	function noise(color::AbstractRGB, s)
		return RGB(noise(color.r, s), noise(color.g, s), noise(color.b, s))
	end
	
	function noise(image::AbstractMatrix, s)
		return noise.(image, s)
	end
end

# ╔═╡ 327c4f54-c107-485c-a96c-3364efe8b92a
@bind image_noise Slider(0:0.01:8, show_value=true)

# ╔═╡ ab877cc6-b526-461a-a4f1-055daa5e3c49
image_noised = noise(image, image_noise)

# ╔═╡ Cell order:
# ╠═363f32d6-a758-47b8-8ea4-b71552e191e4
# ╠═a78de663-bb10-437c-a2a3-46b662414ca0
# ╠═b6434fca-c3dd-4d93-b4ba-84e6062acb92
# ╟─bfd8d202-86b1-4b1b-8b0b-466226365636
# ╠═fddd9677-a3c3-4d1b-8520-2bf984b69f5d
# ╠═6e6aa95c-c304-43bc-94a1-704cc8fce4ee
# ╟─4e0757c2-2267-43cd-a310-23294fffe1b3
# ╠═c50fcdc5-3bad-4ac9-baa4-8b171deb92f0
# ╠═34af6aa6-5933-46d6-ac6e-889e8667fad0
# ╠═6b51f016-73ad-40d5-a6a0-121a63c1f370
# ╠═89d9a367-cedd-4065-9748-aceb42591fd8
# ╠═9fc41f76-5ae2-4a10-af4c-fd05a3394c8e
# ╠═f7421afa-58b1-4a73-831b-07d21eefda13
# ╠═babab1f3-acfe-4e40-9db0-6928a62ba986
# ╠═93104e3c-e6fe-42b1-82c4-8a5731d6c01b
# ╠═e7643df0-92d7-450f-a6f9-978ddf4321d9
# ╠═bedcd25c-66c2-4efc-aca8-5fdb8d70c3ba
# ╠═d2fe1c60-a2cc-42d8-af58-a7a1eec4cdff
# ╠═345f5783-ca7b-4b93-b729-84587e713fb4
# ╠═0ee499b1-4af8-4695-86d1-54fae5f9232e
# ╠═ca8c9a51-83d9-41de-af45-d573766142e0
# ╠═91354607-e728-4b44-bc68-f9fb856678dd
# ╠═9a2fc770-1c18-4dcc-a6db-02dee026aee3
# ╠═64fdf308-836b-42f1-a2df-822c4605d2f9
# ╠═95bde916-34cc-494e-b0fc-72b90d951408
# ╠═a0b2b8ce-222d-472f-9ae2-2ebdd3166612
# ╠═5ed829b7-2c51-4739-bb35-b64085ae99cc
# ╠═327c4f54-c107-485c-a96c-3364efe8b92a
# ╠═ab877cc6-b526-461a-a4f1-055daa5e3c49
