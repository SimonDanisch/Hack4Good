using Twitter

twitterauth("6TSknsNIdIB0SpjEPvmwGLO8F", 
            "C2m5jbodDVemnbGiD0rPDxFu3lptIvbWQ3VQHi2mELF1UrwUoG", 
            "71555548-HhUJKhkr6MkXgB0IXG6QYDKunHszeQ2KBHiDkg4zv", 
            "gh2zmIUDopVuDo9KICydIwQHGmulrolzju9BI13tGvToA")

tweets1 = get_search_tweets("#terrorists"; options = {"count" => "5"})

tweets2 = get_search_tweets("#behappy"; options = {"count" => "5"})

t1 = [length(tweets1[1].text), length(tweets1[2].text), length(tweets1[3].text), length(tweets1[4].text), length(tweets1[5].text)]

t2 = [length(tweets2[1].text), length(tweets2[2].text), length(tweets2[3].text), length(tweets2[4].text), length(tweets2[5].text)]

using Gadfly

function main(window)
    plot(
        x = t1, y = t2, Theme(panel_fill=colorant"black", default_color=colorant"#FF36E5"), Geom.point, Geom.line
        )
end
