FROM directus/directus:11.12.0

#
# 将项目内的 extensions 打包进镜像，适配两种来源：
# 1) 传统文件系统扩展：/directus/extensions/**
# 2) Registry 安装缓存：/directus/node_modules/.directus/extensions/.registry/**
# 这样在生产环境无需挂载卷即可使用扩展
#

ENV EXTENSIONS_PATH=/directus/extensions

# 预创建目录（镜像里默认存在，但显式创建更稳妥）
RUN mkdir -p /directus/extensions \
    && mkdir -p /directus/node_modules/.directus/extensions/.registry

# 将本地 extensions 复制到镜像
# - 若存在 .registry，则拷入 directus CLI 期望的位置以模拟已安装的 registry 扩展
# - 其余非常规目录（自定义文件系统扩展）则拷入 /directus/extensions
COPY ./extensions/.registry /directus/node_modules/.directus/extensions/.registry
COPY ./extensions /directus/extensions

# 统一权限到运行用户，避免容器内权限问题
RUN chown -R node:node /directus/extensions /directus/node_modules/.directus

# 如需进一步在构建时安装额外扩展（联网环境）：
# 取消注释下方示例，并替换为你的扩展包名
# RUN npx --yes directus-extension install @directus-labs/simple-list-interface@1.0.0

# 其余运行配置由基础镜像的入口点处理，此处不覆盖 CMD/ENTRYPOINT