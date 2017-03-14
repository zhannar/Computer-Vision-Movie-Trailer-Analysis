function att = att_ext(bow, lbp, gist, colorhist, model_all)

fea = [l2nor(bow), l2nor(lbp), l2nor(gist), l2nor(colorhist)];
fea = l2nor(fea);
%size(fea)
att = fea*model_all';
att = l2nor(att);

end

function [ X ] = l2nor( X )
for i = 1:size(X)
    X(i,:) = X(i,:)/norm(X(i,:),2);
end
end

