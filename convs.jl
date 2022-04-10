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

# ╔═╡ 45f98f2c-44f2-4603-aa74-068a03d3b367
begin
	import Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ d9f9d240-9d19-4027-9aac-0b842d98095e
begin
	Pkg.add(["Images", "ImageMagick"])
	using Images
end

# ╔═╡ d1c5935b-9bff-41b1-81d8-16f778b2772e
begin
	Pkg.add("PlutoUI")
	using PlutoUI
end

# ╔═╡ 964d08c6-accb-4747-a7da-a179e642ff1d
image_file = download("https://i.imgur.com/bIRGzVOb.jpg")

# ╔═╡ 64d3a98e-7ee6-45c2-9eed-8d9f81085e33
### To take a picture ###

# @bind raw_camera_data camera_input(;max_size=100)
# camera_image = process_raw_camera_data(raw_camera_data);

# ╔═╡ 610375ae-f4a1-41a3-9286-42be64406f91
image = Images.load(image_file)

# ╔═╡ 6fb5ba52-ead4-4229-b9c0-0d94b2719a32
md"""Convolve"""

# ╔═╡ 7491ce93-65a2-4ca5-92da-2c1362586a6c
function extend_mat(M::AbstractMatrix, i, j)
	return M[clamp(i,1,size(M,1)),clamp(j,1,size(M,2))]
end

# ╔═╡ b82b72b4-7dd8-4d28-b126-b273f448e3ee
function convolve(M::AbstractMatrix, K::AbstractMatrix)
	new_M = fill(RGB(0.0,0.0,0.0),size(M))
	row_k,col_k = size(K) 
	rk_l = Int((row_k-1)/2)
	ck_l = Int((col_k-1)/2)
	for i in 1:size(M,1)
		for j in 1:size(M,2)
			ext_M = [extend_mat(M,_i,_j) for (_i,_j) in Iterators.product((-rk_l+i:rk_l+i),(-ck_l+j:ck_l+j))]		
			temp_M = sum(ext_M.*K)
			new_M[i,j]=temp_M
		end
	end
	return new_M
end

# ╔═╡ 29be215f-6eec-4801-a23d-7f6c24838e7c
md"""Sharpen"""

# ╔═╡ 7645ce83-b553-4f72-aef2-6db4c7538aeb
K_sharpen = [
	0 -1 0
	-1 5 -1
	0 -1 0
]

# ╔═╡ 0b12b1f7-fb22-44ba-951c-9839f1314931
image_sharpen = convolve(image, K_sharpen)

# ╔═╡ ad39116d-74a1-44d6-a642-47124f05524d
md"""Laplacian"""

# ╔═╡ 14ecea50-e4fc-4c4e-a2ab-d72bde14a7dd
K_lap = [
	0 -1 0
	-1 4 -1
	0 -1 0
]

# ╔═╡ 58f66060-b78c-41c6-bb2b-26fd8d434265
image_lap = convolve(image, K_lap)

# ╔═╡ 600c0274-7c2d-4fa6-9e12-f3b8d3ca90c4
md"""Sobel"""

# ╔═╡ 4b84b721-ffd2-422b-9f6b-4b4dafa5b9fb
function sobel(image)
	kx = [1 0 -1; 2 0 -2; 1 0 -1] # horizontal direction
	ky = [1 2 1; 0 0 0; -1 -2 -1] # vertical direction
	Gx = convolve(image, kx)
	Gy = convolve(image, ky)
	square(pixel) = RGB(pixel.r*pixel.r, pixel.g*pixel.g, pixel.b*pixel.b)
	square_root(pixel) = RGB(sqrt(pixel.r),sqrt(pixel.g),sqrt(pixel.b))
	Gtotal(img1, img2) = square_root.(square.(img1) + square.(img2)) # calculate gradient
	return Gtotal(Gx, Gy)
end

# ╔═╡ 8901c2d3-747e-40e8-8aef-bb4c0034f38b
image_sobel = sobel(image)

# ╔═╡ 3b72888e-ed0d-4b47-a5ca-3451dc2688ed
md"""Emboss"""

# ╔═╡ a311baa7-1de8-4d29-82c2-fc8724c91ec3
K_emboss = [
	-2 -1 0
	-1 1 1
	0 1 2
]

# ╔═╡ d1e86bae-1fd4-4633-b72e-64324cf2809e
image_emboss = convolve(image, K_emboss)

# ╔═╡ 114fce3f-6126-42c2-9214-a1d829b645aa
md"""Gaussian blur"""

# ╔═╡ 810575fa-e578-4fd8-a7fc-ce13a47ff3ef
function gaussian_blur(image, σ, n)  
	g(x, y) = (1/(2*π*σ*σ))*exp(-(x^2 + y^2)/(2*σ*σ)) 
	kernel = zeros(2*n+1, 2*n+1)
	for (i_idx,i) in enumerate(-n:1:n)
		for (j_idx,j) in enumerate(-n:1:n)
			kernel[i_idx, j_idx] = g(i, j)
		end
	end
	kernel = (kernel)./sum(kernel)
	return convolve(image,kernel)
end

# ╔═╡ f17efbd3-4702-4e10-8986-7dd3bc800dcf
@bind σ Slider(1:25, show_value=true)

# ╔═╡ 21061551-191c-4da2-b4c9-1d1478ae3a46
image_guassian = gaussian_blur(image, σ, 2*σ)

# ╔═╡ Cell order:
# ╠═45f98f2c-44f2-4603-aa74-068a03d3b367
# ╠═d9f9d240-9d19-4027-9aac-0b842d98095e
# ╠═d1c5935b-9bff-41b1-81d8-16f778b2772e
# ╠═964d08c6-accb-4747-a7da-a179e642ff1d
# ╠═64d3a98e-7ee6-45c2-9eed-8d9f81085e33
# ╠═610375ae-f4a1-41a3-9286-42be64406f91
# ╠═6fb5ba52-ead4-4229-b9c0-0d94b2719a32
# ╠═7491ce93-65a2-4ca5-92da-2c1362586a6c
# ╠═b82b72b4-7dd8-4d28-b126-b273f448e3ee
# ╠═29be215f-6eec-4801-a23d-7f6c24838e7c
# ╠═7645ce83-b553-4f72-aef2-6db4c7538aeb
# ╠═0b12b1f7-fb22-44ba-951c-9839f1314931
# ╠═ad39116d-74a1-44d6-a642-47124f05524d
# ╠═14ecea50-e4fc-4c4e-a2ab-d72bde14a7dd
# ╠═58f66060-b78c-41c6-bb2b-26fd8d434265
# ╠═600c0274-7c2d-4fa6-9e12-f3b8d3ca90c4
# ╠═4b84b721-ffd2-422b-9f6b-4b4dafa5b9fb
# ╠═8901c2d3-747e-40e8-8aef-bb4c0034f38b
# ╠═3b72888e-ed0d-4b47-a5ca-3451dc2688ed
# ╠═a311baa7-1de8-4d29-82c2-fc8724c91ec3
# ╠═d1e86bae-1fd4-4633-b72e-64324cf2809e
# ╠═114fce3f-6126-42c2-9214-a1d829b645aa
# ╠═810575fa-e578-4fd8-a7fc-ce13a47ff3ef
# ╠═f17efbd3-4702-4e10-8986-7dd3bc800dcf
# ╠═21061551-191c-4da2-b4c9-1d1478ae3a46
