#!/bin/bash
# Default variables
function="install"
full_node="false"

# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script installs a Moonbeam node"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h,  --help       show the help page"
		echo -e "  -fn, --full-node  install full node (default is ${C_LGn}collator${RES})"
		echo -e "  -u,  --update     update the node"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Moonbeam/blob/main/multi_tool.sh — script URL"
		echo -e "https://teletype.in/@letskynode/Moonbeam_EN — English-language guide"
		echo -e "https://teletype.in/@letskynode/Moonbeam_RU — Russian-language guide"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0 2>/dev/null; exit 0
		;;
	-fn|--full-node)
		full_node="true"
		shift
		;;
	-u|--update)
		function="update"
		shift
		;;
	*|--)
		break
		;;
	esac
done

# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
install() {
	if [ ! -n "$moonbeam_moniker" ]; then
		printf_n "${C_LGn}Enter a node moniker${RES}"
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n moonbeam_moniker
	fi
	sudo apt update
	sudo apt upgrade -y
	sudo apt install wget jq bc build-essential -y
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/installers/docker.sh)
	mkdir -p $HOME/.moonbase-alpha
	sudo chown -R $(id -u):$(id -g) $HOME/.moonbase-alpha
	if [ -n "$moonbeam_moniker" ]; then
		if [ "$full_node" = "true" ]; then
			docker run -dit --name moonbeam_node --restart always --network host -v $HOME/.moonbase-alpha:/data -u $(id -u ${USER}):$(id -g ${USER}) purestake/moonbeam --base-path data --chain alphanet  --name "$moonbeam_moniker" --execution wasm --wasm-execution compiled --pruning archive --state-cache-size 1 -- --pruning archive --name "$moonbeam_moniker (Embedded Relay)"
		else
			docker run -dit --name moonbeam_node --restart always --network host -v $HOME/.moonbase-alpha:/data -u $(id -u ${USER}):$(id -g ${USER}) purestake/moonbeam --base-path data --chain alphanet  --name "$moonbeam_moniker" --validator --execution wasm --wasm-execution compiled --pruning archive --state-cache-size 1 -- --pruning archive --name "$moonbeam_moniker (Embedded Relay)"
		fi
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n moonbeam_log -v "docker logs moonbeam_node -fn 100" -a
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n aleo_node_info -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Moonbeam/main/node_info.sh) 2> /dev/null" -a
		printf_n "
The node was ${C_LGn}started${RES}.

\tv ${C_LGn}Useful commands${RES} v

To view the information about the node: ${C_LGn}moonbeam_node_info${RES}
To view the node log: ${C_LGn}moonbeam_log${RES}
To restart the node: ${C_LGn}docker restart moonbeam_node${RES}
"

	else
		printf_n "${C_R}You didn't set up the node moniker!${RES}"
	fi
}
update() {
	printf_n "${C_LGn}Checking for update...${RES}"
	status=`docker pull purestake/moonbeam`
	if ! grep -q "Image is up to date for" <<< "$status"; then
		printf_n "${C_LGn}Updating...${RES}"
		local inspect=`docker inspect moonbeam_node 2>&1`
		local validator=`echo "$inspect" | grep validator`
		docker stop moonbeam_node
		docker rm moonbeam_node
		if [ ! -n "$validator" ] || echo "$inspect" | grep -q "No such object"; then
			docker run -dit --name moonbeam_node --restart always --network host -v $HOME/.moonbase-alpha:/data -u $(id -u ${USER}):$(id -g ${USER}) purestake/moonbeam --base-path data --chain alphanet  --name "$moonbeam_moniker" --execution wasm --wasm-execution compiled --pruning archive --state-cache-size 1 -- --pruning archive --name "$moonbeam_moniker (Embedded Relay)"
		else
			docker run -dit --name moonbeam_node --restart always --network host -v $HOME/.moonbase-alpha:/data -u $(id -u ${USER}):$(id -g ${USER}) purestake/moonbeam --base-path data --chain alphanet  --name "$moonbeam_moniker" --validator --execution wasm --wasm-execution compiled --pruning archive --state-cache-size 1 -- --pruning archive --name "$moonbeam_moniker (Embedded Relay)"
		fi
	else
		printf_n "${C_LGn}Node version is current!${RES}"
	fi
}

# Actions
sudo apt install wget -y &>/dev/null
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
cd
$function
