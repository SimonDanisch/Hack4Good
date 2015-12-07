using FileIO, Colors, GLVisualize, Twitter
import Images
#=
twitterauth("h1ZFui1OhYdsFCJcdj5lzbqJB", 
            "f9vAzj5wgHr4JovFbMeSlf9mz7iGC3PJ5OA0BbPEoPW71d6u2b",
            "1271768347-CdrHL50Bw2otJmeslW7Zsu2NmwZRI60S2XAVZJj",
            "AtmHo9RA9BaW7ineiR2S3JjAJh2oKXVZwpOr8TSYDaHxH")

tweets = get_search_tweets("fluechtlinge",                      
    options=Dict(                        
		"count" => "100",
		"vertical" => "news"
    )
)
fs = open("tweets.jls", "w")
serialize(fs, tweets)
close(fs)
=#
fs = open("tweets.jls", "r")
tweets = deserialize(fs)
close(fs)

convert_img(x::Images.Image) = convert_img(x.data)
convert_img(x::Array) = map(BGRA{U8}, x)
convert_img{T}(x::Array{T, 3}) = map(BGRA{U8}, x[1:end, 1:end, 1])

text = [tweet.text for tweet in tweets]
locations = [tweet.user["location"] for tweet in tweets]
using GLVisualize, GLAbstraction, GeometryTypes, Reactive
sleep(0.5)
w,r = glscreen()
retweets = Float32[tweet.retweet_count for tweet in tweets]
retweets_sorted = sortperm(retweets)
tweets_filtered = tweets[retweets_sorted[1:50]]

const images = Matrix{BGRA{U8}}[convert_img(load(download(tweet.user["profile_image_url"]))) for tweet in tweets_filtered]

#texts = Context[visualize(im, model=translationmatrix(Vec3f0(50,0,0)), boundingbox=Signal(AABB{Float32}(Vec3f0(50,0,0), Vec3f0(500, 40, 0)))) for im in text]
#view(visualize(texts, gap=Vec3f0(5)), method=:orthographic_pixel)
println(locations)
const T = true
const F = false
const good_bad = [
	T, #1
	T,
	T,
	F,
	F, #5
	T, 
	T,
	T,
	T,
	T, #10
	F, 
	T,
	T,
	T,
	T, #15
	T, 
	T,
	F,
	T,
	F, #20
	T,
	T,
	F,
	T,
	T, #25
	T,
	T,
	T,
	F,
	T, #30
	T, 
	T,
	T,
	F,
	T, #35
	T, 
	T,
	F,
	F,
	T, #40
	F, 
	T,
	T,
	F,
	T, #45
	T,
	T,
	F,
	T,
	F, #50
]
colors = convert(Vector{RGBA{U8}}, map(good_bad) do x
	if x 
		RGBA{U8}(1,0,0,1)
	else
		RGBA{U8}(0,1,0,1)
	end
end)

rwidth 	  = 80f0
positions = Point2f0[Point2f0(i*(rwidth+10), 0) for i=1:length(images)]
profilpic = visualize((Circle(Point2f0(0), rwidth), positions), image=images)

popup_rect = map(w.area) do wa
	[Point2f0(100,200)], [Vec2f0(wa.w-200, wa.h-300)]
end


ishover = preserve(is_hovering(profilpic.children[], w))
popup = visualize(
	(ROUNDED_RECTANGLE, map(first, popup_rect)), 
	scale 			= map(last, popup_rect),
	color 			= RGBA{Float32}(1,1,1,1),
	stroke_color 	= GLVisualize.default(RGBA),
	stroke_width 	= 10f0,
	visible 		= ishover
)
mousehover = w.inputs[:mouse_hover]
function prepare_text(text)
	io = IOBuffer()
	splitnext = false
	for (i, elem) in enumerate(text)
		if i % 30 == 0
			splitnext = true
		end
		if splitnext && (elem == ' ' || elem == '\n')
			print(io, '\n')
			splitnext = false
		else
			print(io, elem)
		end
	end
	takebuf_string(io)
end
model = const_lift(popup_rect) do wa
	_, tp = wa
	translationmatrix(Vec3f0(150,tp[][2]-20,-10))*scalematrix(Vec3f0(2))
end
popup_texts = [visualize(
	prepare_text(tweet.text),
	model   = model,
	visible = false
) for tweet in tweets_filtered]

preserve(foldp(0, droprepeats(mousehover)) do pi, mh
	if pi >0 && pi<length(popup_texts)
		 popup_texts[pi].children[][:visible] = false
	end
	if (mh[1]==profilpic.children[].id) && mh[2]>0 && mh[2]<length(popup_texts)
		popup_texts[mh[2]].children[][:visible] = true
		return mh[2]
	end
	0
end)


retweets_scaled = (retweets[retweets_sorted[1:50]].*100) .+ 10f0
bars 	  = Vec3f0[Vec3f0(rwidth-10, count, rwidth) for count in retweets_scaled]

unitcube  = Cube{Float32}(Vec3f0(0), Vec3f0(1))
p3d 	  = Point3f0[Point3f0(elem, 0) for elem in positions]
view(visualize((unitcube,p3d), scale=bars,color=colors, model=translationmatrix(Vec3f0(0,rwidth+10, 0))), method=:orthographic_pixel)
view(profilpic, method=:orthographic_pixel)
for elem in popup_texts
	view(elem, method=:fixed_pixel)
end
view(popup,method=:fixed_pixel)


r()
