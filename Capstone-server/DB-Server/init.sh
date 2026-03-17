# 패키지  업데이트
sudo dnf update -y
sudo dnf install mariadb-server mariadb -y

# 서비스 자동 시작 등록 및 실행
sudo systemctl enable --now mariadb

# 초기 설정 - root 비밀번호, root 원격 접속 로그인 방식 등등
sudo mysql_secure_installation

sudo firewall-cmd --state
sudo systemctl start(enable) firewalld
sudo firewall-cmd --permanent --add-service=mysql
sudo firewall-cmd --reload

# Master 설정파일 수정
sudo vi /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
server-id = 1              # Master 고유 ID (1을 권장)
log-bin = mysql-bin        # 바이너리 로그 활성화
bind-address = 192.168.3.10     # 외부 접속 허용 (특정 IP만 허용해도 됨)

sudo systemctl restart mariadb



# Master DB 접속후
-- 복제 전용 사용자 생성 및 권한 부여
GRANT REPLICATION SLAVE ON *.* TO 'slave'@'192.168.3.20' IDENTIFIED BY '${password}';
FLUSH PRIVILEGES;


SHOW MASTER STATUS;

# Slave 설정파일 수정
sudo vi /etc/my.cnf.d/mariadb-server.cnf

[mysqld]
server-id = 2

sudo systemctl restart mariadb
sudo mysql -u root -p

CHANGE MASTER TO
  MASTER_HOST='192.168.3.10',
  MASTER_USER='slave',
  MASTER_PASSWORD='${password}',
  MASTER_LOG_FILE='mysql-bin.000001',  -- Master에서 확인한 File 값 입력
  MASTER_LOG_POS=${pos};                  -- Master에서 확인한 Position 값 입력

-- 복제 시작
START SLAVE;

-- 복제 상태 확인
SHOW SLAVE STATUS\G