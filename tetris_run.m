global S;
global r_col;
global X;
global Y;
global g1;
try
    rng('shuffle');  % So each game is not the same! RNG is new in r2011a.
catch  %#ok
    rand('twister',sum(100*clock));  %#ok Should work back to r2006a.
end

f_clr = [.741 .717 .42]; % Allows for easy change.  Figure color.
S.fig = figure('units','pixels',...
               'name','Tetris',...
               'menubar','none',...
               'numbertitle','off',...
               'position',[100 100 650 720],...
               'color',f_clr,...
               'keypressfcn',@fig_kpfcn2,...%
               'closereq',@fig_clsrqfcn,...%
               'busyaction','cancel',...
               'renderer','opengl',...
               'windowbuttondownfcn',@fig_wbdfcn,...
               'resizefcn',@fig_rszfcn);
S.pbt = uicontrol('units','pix',...
                  'style','pushbutton',...
                  'position',[420 30 200 100],...
                  'fontweight','bold',...
                  'fontsize',20,...
                  'string','Start',...
                  'callback',@pbt_call,...
                  'enable','off',...
                  'busyaction','cancel');
S.axs = axes('units','pix',...
             'position',[420 460 200 200],...
             'ycolor',f_clr,...
             'xcolor',f_clr,...
             'color',f_clr,...
             'xtick',[],'ytick',[],...
             'xlim',[-.1 7.1],...
             'ylim',[-.1 7.1],...
             'visible','off'); % This axes holds the preview.
r_col = [.85 .95 1]; % The color of the rectangles.
S.rct = rectangle('pos',[0 0 7 7],...
                  'curvature',.3,...
                  'facecolor',r_col,...
                  'edgecolor','r',...
                  'linewidth',2); % This is used below the preview.
S.tmr = timer('Name','Tetris_timer',...
              'Period',1,... % 1 second between moves time.
              'StartDelay',1,... %
              'TasksToExecute',50,... % Will be restarted many times.
              'ExecutionMode','fixedrate',...
              'TimerFcn',@game_step); % Function def. below.
S.axs(2) = axes('units','pix',...
                'position',[410 130 220 320],...
                'ycolor',f_clr,...
                'xcolor',f_clr,...
                'xtick',[],'ytick',[],...
                'xlim',[-.1 1.1],...
                'ylim',[-.1 1.1],...
                'visible','off'); % Points/Lines holder
S.rct(2) = rectangle('pos',[0 0 1 1],...
                     'curvature',.3,...
                     'facecolor',r_col,...
                     'edgecolor','r',...
                     'linewidth',2); % Holds the current stats.
S.DSPDIG(1) = digits(35,5,-50,'Lines');
set(S.DSPDIG(1).ax,'pos',[500 170 0 0]+get(S.DSPDIG(1).ax,'pos'));
S.DSPDIG(2) = digits(35,8,10,'Points');
set(S.DSPDIG(2).ax,'pos',[438 260 0 0]+get(S.DSPDIG(2).ax,'pos'));
S.DSPDIG(3) = digits(35,3,-90,'Level');
set(S.DSPDIG(3).ax,'pos',[540 350 0 0]+get(S.DSPDIG(3).ax,'pos'));
set(S.DSPDIG(3).ax,'visible','on')
digits(S.DSPDIG(3),sprintf('%i',1))
S.axs(3) = axes('units','pix',...
                'position',[30 30 360 630],...
                'ycolor',f_clr,...
                'xcolor',f_clr,...
                'xtick',[],'ytick',[],...
                'xlim',[-1 11],...
                'ylim',[-1 20],...
                'color',f_clr,...
                'visible','off'); % The main board
% Template positions for the patch objects (bricks) in both axes.
X = [0 .2 0;.2 .8 .2;.2 .8 .8;.8 .2 .8;1 .2 1;0 .2 1;0 .2 0];
Y = [0 .2 0;.2 .2 .2;.8 .8 .2;.8 .8 .8;1 .2 1;1 .2 0;0 .2 0];
g1 = repmat([.9 .65 .4],[1,1,3]); % Grey color used throughout.
S.PRVPOS{1} = [1.5 2.5 3.5 4.5;3 3 3 3]; % Positions of the previews.
S.PRVPOS{2} = [2 3 3 4;2.5 2.5 3.5 2.5]; % 1-I,2-T,3-L,4-J,5-Z,6-S,7-O
S.PRVPOS{3} = [2 3 4 4;2.5 2.5 2.5 3.5];
S.PRVPOS{4} = [2 2 3 4;3.5 2.5 2.5 2.5];
S.PRVPOS{5} = [2 3 3 4;3.5 3.5 2.5 2.5];
S.PRVPOS{6} = [2 3 3 4;2.5 2.5 3.5 3.5];
S.PRVPOS{7} = [2.5 2.5 3.5 3.5;3.5 2.5 3.5 2.5];
% Make the board boarders.
for jj = [-1 10]
    Xi = X + jj;
    
    for ii = -1:19
        patch(Xi,Y+ii,g1,...
              'edgecolor','none',...
              'handlevis','callback') % Don't need these handles.
    end
end

for ii = 0:9
    patch(X+ii,Y-1,g1,'edgecolor','none','handlevis','callback')
end

S.pch = zeros(10,20); % These hold the handles to the patches.

for jj = 0:19 % Make the board squares.
    for ii = 0:9
        if rand<.05 % This simply puts random squares on the board.
            % If you have an older version without BSXFUN, use the second
            % line below and comment out the first line below - IF ERROR.
            R = bsxfun(@minus,.5 + rand(1,1,3)*.5,[0,.25,.5]); % See note! 
% R = repmat(.5 + rand(1,1,3)*.5,[1,3,1])-repmat([0,.25,.5],[1,1,3]);
            S.pch(ii+1,jj+1) = patch(X+ii,Y+jj,R,'edgecolor','none');
            % drawnow   % On faster systems this can look neat.
        else
            S.pch(ii+1,jj+1) = patch(X+ii,Y+jj,'w','edgecolor','w');
        end
    end
end
% Hold the colors of the pieces, and board index where each first appears.
S.PCHCLR = {reshape([1 .75 .5 0 0 0 0 0 0],1,3,3),...
            reshape([0 0 0 1 .75 .5 0 0 0],1,3,3),...
            reshape([0 0 0 0 0 0 1 .75 .5],1,3,3),...
            reshape([1 .75 .5 1 .75 .5 0 0 0],1,3,3),...
            reshape([1 .75 .5 0 0 0 1 .75 .5],1,3,3),...
            reshape([0 0 0 1 .75 .5 1 .75 .5],1,3,3),...
            reshape([.5 .25 0 .5 .25 0 .5 .25 0],1,3,3)}; % Piece colors.
% S.PCHIDX holds the location where each piece first appears on the board.
S.PCHIDX = {194:197,[184 185 186 195],[184 185 186 196],...
            [184 185 186 194],[194 195 185 186],[184 195 185 196],...
            [185 186 195 196]};
S.MAKPRV = true;  % Make a preview or not.
S.CURPRV = []; % Holds current preview patches.
S.PRVNUM = []; % Holds the preview piece number, 1-7.
make_preview;  % Call the function which chooses the piece to go next.
S.BRDMAT = false(10,20); % The matrix game board.
S.CURROT = 1; % Holds the current rotation of the current piece.
S.PNTVCT = [40 100 300 800]; % Holds the points per number of lines.
S.CURLVL = 1; % The current level.
S.CURLNS = 0; % The current number of lines
S.STPTMR = 0; % Kills timer when user is pushing keyboard buttons.
S.SOUNDS = load('splat'); % Used for landing/line sound effect.
S.plr = audioplayer(S.SOUNDS.y,S.SOUNDS.Fs); % player for sounds.
S.CURSCR = 0; % Holds the current score during play.
S.PLRLVL = 1; % The level the player chooses to start...
% These next two dictate how fast the game increases its speed and also how
% many lines the player must score to go up a level, respectively.  The
% first value shoould be on (0,1].  Smaller values increase speed faster.
% No error handling is provided if you use bad values!
S.LVLFAC = .825;  % Percent of previous timerdelay. 
S.CHGLVL = 5; % Increment level every S.CHGLVL lines.

if nargin && isnumeric(varargin{1})
    S.PLRLVL = min(round(max(varargin{1},1)),9);  % Starting level.
    digits(S.DSPDIG(3),sprintf('%i',S.PLRLVL))
end

try
    SCR = load('TETRIS_HIGH_SCORE.mat');
    S.CURHSC = SCR.SCR; % The user has a previous High Score.
catch  %#ok
    S.CURHSC = 0;
end

set(S.fig,'name',['Tetris',' High Score - ', sprintf('%i',S.CURHSC)])
set([S.DSPDIG(:).ax,S.axs(:).',S.pbt,S.DSPDIG(:).tx],...
    'units','norm','fontunits','norm')  % So we can resize the figure.
set(S.pbt,'enable','on') % Turn the game on now that we are ready...


