% from https://github.com/GuntherStruyf/matlab-tools/blob/master/schemaball.m

function schemaball3(ax, corrMatrix, labels, parentLabels,  parentColors)
%% SCHEMABALL(strNames, corrMatrix, fontsize, positive_color_hs, negative_color_hs, theta)
%	inspired by http://mkweb.bcgsc.ca/schemaball
%	discussion at http://stackoverflow.com/questions/17038377
%
%	Draws a circular represenation of a correlation matrix.
%	Use no input arguments for a demo.
%
%INPUT ARGUMENTS
%	strNames	The names of variables of the correlation matrix
%				Format: Mx1 cell array of strings
%	corrMatrix	Correlation matrix (MxM)
%OPTIONAL:
%	fontsize	Font size of the labels along the edge
%				Default: 30/exp(M/30)
%	positive_color_hs:
%				The hue and saturation of the connection lines for
%				variables with a positive correlation.
%	negative_color_hs:
%				The hue and saturation of the connection lines for
%				variables with a negative correlation.
%	theta		Mx1 vector of angles at which the labels and connector
%				lines must be placed. If not supplied, they are evenly
%				distributed along the whole edge of the circle.
%


	%% Check input arguments
    M = size(corrMatrix, 1);
	fontsize = 8;
	theta = linspace(0,2*pi,M+1);
	theta(end)=[];
	positive_color_hs = [0.1587 0.8750]; % yellow

    %% get parent colors indices
    parentLabelsUnique = unique(parentLabels);
    indices_str = zeros(1,length(parentLabelsUnique));
    for idx=1:length(parentLabelsUnique) 
        indices_str(idx) = round(mean(find(strcmp(parentLabels, parentLabelsUnique{idx}))));
    
    end
	
	%% Configuration
	R = 1;
	Nbezier = 100;
	bezierR = 0.1;
	markerR = 0.025;
	labelR1 = 1.1;
    labelR2 = 1.7;
    lineWidth = 2;
	
	%% Create figure with invisible axes, just black background
	hold on
	set(ax,'color','w','XTick',[],'YTick',[]);
	set(ax,'position',[0 0 1 1],'xlim',2*[-1 1]*(R + 0.1),'ylim',2*[-1 1]*(R + 0.1));
	axis(ax, 'equal')
	
	%% draw diagonals
	% if you draw the brightest lines first and then the darker lines, the
	% latter will cut through the former and make it look like they have
	% holes. Therefore, sort and draw them in order (darkest first).
	idx = nonzeros(triu(reshape(1:M^2,M,M),1));
	[~,sort_idx]=sort(abs(corrMatrix(idx)));
	idx = idx(sort_idx);
	
	[Px,Py] = pol2cart(theta,R);
	P = [Px ;Py];
	
	for ii=idx'
		[jj,kk]=ind2sub([M M],ii);
        if abs(corrMatrix(jj,kk)) == 0 || isnan(abs(corrMatrix(jj,kk)))
            continue
        end
		[P1x,P1y] = pol2cart((theta(jj)+theta(kk))/2,bezierR);
		Bt = getQuadBezier(P(:,jj),[P1x;P1y],P(:,kk), Nbezier);
        
%         clr = hsv2rgb([positive_color_hs abs(corrMatrix(jj,kk))]);
        clr_idx = find(strcmp(parentLabelsUnique, parentLabels{jj}));
        clr = [parentColors{clr_idx} abs(corrMatrix(jj,kk))];

		plot(Bt(:,1),Bt(:,2),'color',clr, 'LineWidth',lineWidth);%,'LineSmoothing','on');
	end
	
	%% draw edge markers
	[Px,Py] = pol2cart(theta,R+markerR);
	% base the color of the node on the 'degree of correlation' with other
	% variables:
	corrMatrix(logical(eye(M)))=0;
	V = mean(abs(corrMatrix),2);
	V=V./max(V);
	clr = hsv2rgb([ones(M,1)*[0.585 0.5765] V(:)]);
	
	%scatter(Px,Py,20,clr);%,'filled'); % non-filled looks better imho
	for ii=1:M
        clr_idx = find(strcmp(parentLabelsUnique, parentLabels{ii}));
        color = parentColors{clr_idx};

		rectangle('Curvature',[1 1],'edgeColor',color,...
			'Position',[Px(ii)-markerR Py(ii)-markerR 2*markerR*[1 1]], 'LineWidth',lineWidth);
	end
	
	%% draw labels
% 	[Px,Py] = pol2cart(theta + 0.1,labelR2);
% 	for iii=1:length(parentLabelsUnique)
%         ii = indices_str(iii);
%         color = parentColors{iii};
% 		text(Px(ii),Py(ii),parentLabelsUnique{iii},'Rotation',theta(ii)*180/pi - 90,'color',color, ...
% 			'FontName','FixedWidth','FontSize',fontsize, 'VerticalAlignment','baseline');
%     end
    %% draw all labels
	[Px,Py] = pol2cart(theta,labelR1);
	for ii=1:M
        clr_idx = find(strcmp(parentLabelsUnique, parentLabels{ii}));
        color = parentColors{clr_idx};

		text(Px(ii),Py(ii),labels{ii},'Rotation',theta(ii)*180/pi,'color',color, ...
			'FontName','FixedWidth','FontSize',fontsize, 'VerticalAlignment','baseline');
	end
end
function Bt = getQuadBezier(p0,p1,p2,N)
	% defining Bezier Geometric Matrix B
	B = [p0(:) p1(:) p2(:)]';
	
	% Bezier Basis transformation Matrix M
	M =[1	0	0;
		-2	2	0;
		1	-2	1];
	% Calculation of Algebraic Coefficient Matrix A
	A = M*B;
	% defining t axis
	t = linspace(0,1,N)';
	T = [ones(size(t)) t t.^2];
	% calculation of value of function Bt for each value of t
	Bt = T*A;
end