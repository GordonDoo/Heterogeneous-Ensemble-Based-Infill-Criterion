function [Centers Spreads W2 B2]=clusterRBF(SamIn, SamOut, ClusterNum)
    
    v = size(SamIn,2);
    Overlap = 1.0;% ���ڵ��ص�ϵ��
    SamNum = size(SamIn,1);% ��������
    
    nn=0;
    while (nn==100||nn==0)
        index=randi([1,SamNum],ClusterNum,1);
        Centers = SamIn(index,:);%��ʼ����������
        n=1;
        while n<100,
            NumberInClusters = zeros(ClusterNum,1); % �����е�����������ʼ��Ϊ��
            IndexInClusters = zeros(ClusterNum,SamNum); % ��������������������
            % ����С����ԭ��������������з���
            for i = 1:SamNum
                AllDistance = dist(Centers,SamIn(i,:)');%�����i��ѵ�����������о������ĵľ���
                [MinDist,Pos] = min(AllDistance);   %��С���룬��ѵ�����������ľ�����������
                NumberInClusters(Pos) = NumberInClusters(Pos) + 1;
                IndexInClusters(Pos,NumberInClusters(Pos)) = i;%�����ڸ����ѵ�������������δ���
            end   
            % ����ɵľ�������
            OldCenters = Centers;
            %���¼����������
            for i = 1:ClusterNum
                Index = IndexInClusters(i,1:NumberInClusters(i));%��ȡ���ڸ����ѵ����������
                Centers(i,:) = mean(SamIn(Index,:),1);    %ȡ�����ƽ����Ϊ�µľ�������
            end
            % �ж��¾ɾ��������Ƿ�һ�£������������
            EqualNum = sum(sum(Centers==OldCenters));%Centers��OldCenters���ж�Ӧλ���֮�����ܺ�
            if EqualNum ==v*ClusterNum,%�����¾ɾ�������һ��
                break,
            end
            n=n+1;
        end
        nn=n;
    end
    % ��������ڵ����չ��������ȣ�
    AllDistances = dist(Centers,Centers'); % �������ڵ��������ļ�ľ��루ClusterNumά���ķ��󣬶Գƾ���
    Maximum = max(max(AllDistances)); % �ҳ���������һ������
    for i = 1:ClusterNum % ���Խ����ϵ�0 �滻Ϊ�ϴ��ֵ
        AllDistances(i,i) = Maximum+1;
    end
    Spreads = Overlap*min(AllDistances)'; % �����ڵ�����С������Ϊ��չ����; ��ת��Ϊ������

    % ��������ڵ�����Ȩֵ
    Distance = dist(Centers,SamIn'); % �����������������������ĵľ���(��ClusterNum X SamNum����)
    SpreadsMat = repmat(Spreads,1,SamNum);%��ClusterNum X SamNum����
    HiddenUnitOut = radbas(Distance./SpreadsMat); %�������ڵ������; radbas�Ǿ�������ݺ���
    HiddenUnitOutEx = [HiddenUnitOut' ones(SamNum,1)]'; % ����ƫ��(��ֵ)
    W2Ex = SamOut'*pinv(HiddenUnitOutEx); % ��������Ȩֵ
    W2 = W2Ex(:,1:ClusterNum); % ���Ȩֵ
    B2 = W2Ex(:,ClusterNum+1); % ƫ�ƣ���ֵ��
end